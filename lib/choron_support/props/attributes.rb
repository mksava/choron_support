require_relative "./private/type_builder"
require_relative "./private/setting"
module ChoronSupport::Props::Attributes
  unless defined?(ActiveSupport)
    raise "ActiveSupport is not defined. Please require 'active_support/all' in your Gemfile"
  end

  extend ActiveSupport::Concern

  included do
    # DSLで設定できる設定値たち ==========================
    #  Props作成時に設定されるキーと値を設定します。
    #  この値はDSLを経由して内部的に設定されていきます
    class_attribute :settings, instance_writer: false, default: nil
    #  Props作成時に自動で付与される元のクラスの文字列を設定しないときはtrueを設定してください
    #  @example
    #    class Props::Foos::Bar
    #      self.skip_meta_mark = true
    #    end
    class_attribute :skip_meta_mark, default: false
    # Propsから自動でtypescriptの型を生成しないときはfalseを設定してください
    # @example
    #   class Props::Foos::Bar
    #     self.skip_typescript = true
    #   end
    class_attribute :skip_typescript, default: false
    #  他のPropsクラスの設定を継承するときに設定されます
    class_attribute :inherit_props_class, default: nil
    # ====================================================

    # Propsとして出力する属性を設定するためのDSLです
    # @param [Symbol] method モデル, もしくは to オプションで設定したオブジェクトに対して実行するメソッドを指定してください
    # @param [Keyword] options その他のオプションを指定してください
    #   @option [Symbol] :to 指定したメソッドを実行するオブジェクトを指定できます
    #   @option [Symbol | lambda] :if 属性を出力するための条件を指定できます
    #   @option [Symbol] :cast 属性を出力する前に指定したメソッドを実行できます。
    #   @option [Boolean] :default 属性値がnilのときに代わりに出力する値を指定できます
    #   @option [Proc] &block ブロックを渡すとそのブロックの戻り値を属性値として出力します
    def self.attribute(method, **options, &block)
      setting_params = options.merge(method: method, block: block)
      setting = ChoronSupport::Props::Private::Setting.new(setting_params)

      self.settings ||= []
      self.settings << setting
    end

    # 他のPropsクラスの設定を継承するためのDSLです
    # @param [ChoronSupport::Props::Base] inherit_props_class 継承するPropsクラスを指定してください
    # @example
    #   class Props::Users::General < ChoronSupport::Props::Base
    #     inherit Props::Users::Base
    #   end
    def self.inherit(props_class)
      # 継承するクラスはProps::Baseを継承している必要があります
      unless props_class.ancestors.include?(ChoronSupport::Props::Base)
        raise "inherit class must be ChoronSupport::Props::Base. got: #{props_class}"
      end

      # 既に継承先が設定されている場合はエラーにします
      if self.inherit_props_class.present?
        raise "inherit props inherit class already set: #{self.inherit_props_class}.(Only one class can be inherited)"
      end

      self.inherit_props_class = props_class
      self.settings ||= []
      self.inherit_props_class.settings.to_a.each do |setting|
        self.settings << setting
      end
    end

    # Modelに対して関連付けされた別ModelのPropsを結合するためのDSLです
    # @param [Symbol] method to オプションで指定されたオブジェクトに実行されるメソッドを指定してください
    # @param [ChoronSupport::Props::Base] props モデルをProps化するためのクラスを指定してください
    # @param [Keyword] options その他のオプションを指定してください。詳細は attribute と同じです
    # @example
    #   class Props::Users::General < ChoronSupport::Props::Base
    #     relation :posts, props: Props::Posts::General
    #     #=> { posts: user.posts.as_props(:general) } と同じ結果になる
    #   end
    def self.relation(method, props_class, **options)
      self.attribute(method, **options) do |model, params|
        records = model.send(method)
        records&.as_props(props_class, **params)
      end
    end
  end

  # @return [Hash] props
  def as_props
    _props = {}

    # DSLの設定を設定する
    self.class.settings.to_a.each do |setting|
      _props.merge!(__build_props_attribute__(setting))
    end

    # Classのマークをつける(テスト用)
    _props.merge!(__build_props_class_mark__)
    # Modelのマークをつける
    _props.merge!(__build_props_meta_mark__)

    _props
  end

  private

  def model
    raise NotImplementedError, "model method is not implemented"
  end

  def params
    raise NotImplementedError, "params method is not implemented"
  end

  FORMATS = {
    # HTMLのinput type="date"で使える形式
    date: "%Y-%m-%d",
    datetime: "%Y-%m-%dT%H:%M",
  }.freeze
  # 型のキャスト指定があってもキャストはしないメソッド
  CAST_IGNORE_METHODS = [
    # id は数値のほうが良いため
    :id,
  ].freeze
  # @param [Array<Symbol>] Setting
  def __build_props_attribute__(setting)
    attribute = {}

    _if = setting.if
    if _if.present?
      result = send(_if)
      return {} unless result
    end

    # javascriptは?をキーとして使えないので削除しつつ、isXxx形式に変換する
    key = setting.name
    if key.to_s.end_with?("?")
      key = key.to_s.gsub("?", "").to_sym
      key = "is_#{key}".to_sym unless key.start_with?("is_")
    end

    # valはこの後の工程で書き換えの可能性があるため注意
    val = nil
    method = setting.method
    to = setting.to
    if setting.block.present?
      val = setting.block.call(model, params)
    else
      if to == :self
        if method.is_a?(Proc)
          val = method.call(self)
        else
          val = send(method)
        end
      else
        if method.is_a?(Proc)
          val = method.call(send(to))
        else
          val = send(to)&.send(method)
        end
      end
    end

    case val
    when Date
      val = val.strftime(FORMATS[:date])
    when ActiveSupport::TimeWithZone, Time
      # 日付系であればjsで使えるようにhtmlに変換する
      val = val.strftime(FORMATS[:datetime])
    else
      if setting.cast.present? && CAST_IGNORE_METHODS.exclude?(key)
        val = setting.cast.to_s.split(".").inject(val) do |lval, cast_method|
          lval.send(cast_method)
        end
      end
    end

    if val.nil? && setting.set_default?
      val = setting.default
    end

    attribute[key] = val

    attribute
  end

  # テストモードのときはどのPropsを実行したかを判定できるように属性をつけたします
  def __build_props_class_mark__
    mark = {}
    if ENV["RAILS_ENV"] == "test"
      mark[:props_class_name] = self.class.name
      if self.class.inherit_props_class.present?
        mark[:inherit_props_class_name] = self.class.inherit_props_class.try(:name) || self.class.inherit_props_class.to_s
      end
    end

    mark
  end

  # どのモデルのPropsかを判定できるように属性をつけたします
  def __build_props_meta_mark__
    return {} if self.class.skip_meta_mark

    type_target = begin
      model
    rescue StandardError
      self
    end

    {
      type: type_target.class.try(:name).to_s,
      model_name: type_target.class.try(:name).try(:demodulize).to_s,
    }
  end
end
