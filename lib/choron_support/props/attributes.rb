# 本クラス は include 先のクラスに対してキャメルケースのJSONを設定するためのDSLやメソッドを提供するモジュールです
# このモジュールをincludeしたクラスは以下のような形で使うことを想定しています
# @examle
#   [app/models/values/money.rb]
#   class Values::Money
#     include ChoronSupport::Props::Attributes
#     attributes :amount, :amount_with_unit, to: :self
#     def initialize(amount)
#       @amount = amount.to_i
#     end
#     def amount
#       @amount
#     end
#     def amount_with_unit
#       "#{amount}円"
#     end
#   end
# Choronではデフォルトで以下のようなBaseクラスが作成されて、読み込みがされています
# @example
#   class Props::Base < ChoronSupport::Props::Base
#     include ChoronSupport::Props::Attributes
#   end
# [使い方]
# @example 最も簡単な例
#   [app/models/props/user.rb]
#   class Props::User < Props::Base
#     # id, full_name, ageを出力させる
#     # retult: { id: 1, fullName: "John Smith", age: 20 }
#     attributes :id, :full_name, :age
#   end
# @example メソッドのデリゲート先を指定する
#   [app/models/props/user.rb]
#   class Props::User < Props::Base
#     # result: { fullName: "John Smith" }
#     attributes :full_name, to: :self
#     def full_name
#       "#{model.first_name} #{model.last_name}"
#     end
#   end
# @example 関連先のModelのPropsを結合する
#   class Props::User < Props::Base
#     # result: { posts: posts.as_props } => { posts: [{ id: 1, title: "foo" }, { id: 2, title: "bar" }] }
#     relation :posts
#   end
#
# これらの各種DSLは複数同時に設定することもできます
# @example 複数設定
#   [app/models/props/user.rb]
#   class Props::User < Props::Base
#     # id, full_name, ageを出力させる
#     attributes :id, :age
#     attributes :full_name, to: :self
#     relation :posts
#     def full_name
#       "#{model.first_name} #{model.last_name}"
#     end
#   end
#
# default値の設定やifオプションを渡して出力有無を動的に変更もできます
# @example default, ifの設定
#   [app/models/props/user.rb]
#   class Props::User < Props::Base
#     # age が nil のときは 0 を出力する
#     # age が 20 以上のときのみ出力する
#     attributes :age, default: 0, if: :show_age?
#     def show_age?
#       model.age >= 20
#     end
#   end
#
#
# 本DSLを利用するときは基本的には attributes を使って設定するのが良いと思います
# 細かな使い方モジュールの該当DSL(self.xxxx)の説明を参照してください
module ChoronSupport
  module Props
    module Attributes
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
      # デフォルト値を設定しない場合に使う値
      NO_DEFAULT = Object.new.freeze

      extend ActiveSupport::Concern

      included do
        # 本moduleはActiveSupportが使える環境でのみ動作します
        unless defined?(ActiveSupport)
          raise "ActiveSupport is not defined. Please require 'active_support/all' in your Gemfile"
        end

        # DSLで設定できる設定値たち ==========================
        #  Props作成時に設定されるキーと値を設定します。
        #  この値はDSLを経由して内部的に設定されていきます
        class_attribute :settings_attributes
        #  Props作成時に自動で付与される元のクラスの文字列を設定しないときはtrueを設定してください
        #  @example
        #    class Props::Foo < Props::Base
        #      self.skip_meta_mark = true
        #    end
        class_attribute :skip_meta_mark, default: false
        #  他のPropsクラスの結果を結合するときに結合先のProps識別子を設定してください
        # @example
        #   class Props::Foos::General < Props::Base
        #     # すべてのカラムを出す
        #     self.union = :model
        #     # as_props の結果を結合する
        #     self.union = :default
        #     # as_props(:secure) の結果を結合する
        #     self.union = :secure
        #   end
        class_attribute :union, default: nil
        # ====================================================

        # Props作成時に設定されるキーと値を設定します。
        # @param [Symbol] key Propsのキーを指定してください
        # @param [Symbol] method 値を代入するためのメソッドを指定してください。指定がないときはkeyをメソッドとして扱います
        # @param [Symbol] to メソッドのデリゲート先を指定してください。指定がないときはmodelをデリゲート先として扱います。:selfを指定すると自身をデリゲート先として扱います
        # @param [Symbol] cast デリゲート先のメソッドの戻り値に対して、さらにメソッドを実行するときは指定してください。
        # @param [Object] default 値がnilのときに設定されるデフォルト値を指定してください。指定がないときはnilになります。
        # @param [Proc | Symbol] if その値を出すときの条件。Symbolだとselfに対してsendを実行します
        def self.attribute(key, method: nil, to: :model, cast: nil, default: NO_DEFAULT, if: nil)
          self.settings_attributes ||= []
          self.settings_attributes << { key:, to:, method: (method || key), cast:, default:, if: }
        end

        # 一度にまとめて複数のattributeを設定します
        # 基本的なパラメータの説明はattributeを参照してください
        # @param [Array<Symbol>] methods 設定するキーと値のペアを指定してください
        # @example
        #   model = User.new(id: 1, name: "John", email: "JOHN@EXAMPLE", age: nil)
        #   class Props::User::Foo < ChoronSupport::Props::Base
        #     attributes :id, :name, :email, :age
        #       #=> { id: 1, name: "John", email: "JOHN@EXAMPLE", age: nil }
        #   end
        # @note to, cast, defaultなどのパラメータについて
        #   これらの値は全てのメソッド・キーに対して同じ値が設定されます
        def self.attributes(*methods, to: :model, cast: nil, default: NO_DEFAULT, if: nil)
          methods.each do |method|
            attribute(method, method:, to:, cast:, default:, if:)
          end
        end

        # Modelに対して関連付けされた別ModelのPropsを結合するためのDSLです
        # to, cast, default, if については attribute と同じです
        # @param [Symbol] key Propsのキーを指定してください
        # @param [Symbol] relation 結合するModelのメソッドを指定してください。指定がないときはkeyをメソッドとして扱います
        # @example
        #   class Props::User < ChoronSupport::Props::Base
        #     relation :posts
        #     #=> { posts: user.posts.as_props } と同じ結果になる
        #     relation :posts, props: :foo_bar
        #     #=> { posts: user.posts.as_props(:foo_bar) } と同じ結果になる
        #     relation :user_posts, relation: :posts
        #     #=> { user_posts: user.posts.as_props } と同じ結果になる
        #   end
        def self.relation(key, relation: nil, to: :model, cast: nil, default: NO_DEFAULT, props: nil, if: nil)
          relation ||= key
          method = lambda { |model|
            records = model.send(relation)
            if props
              records&.as_props(props) || {}
            else
              records&.as_props || {}
            end
          }
          self.attribute(
            key,
            method:,
            to:,
            cast:,
            default:,
            if:,
          )
        end

        # self.relation の複数同時に設定ができるversionです
        # 基本は上記と一緒ですが、relationとkeyは同じである必要があります
        # @example
        #   class Props::User < ChoronSupport::Props::Base
        #     relations :posts, :comments
        #     #=> { posts: user.posts.as_props, comments: user.comments.as_props } と同じ結果になる
        #   end
        def self.relations(*keys, to: :model, cast: nil, default: NO_DEFAULT, props: nil, if: nil)
          keys.each do |key|
            method = lambda { |model|
              records = model.send(key)
              if props
                records&.as_props(props) || {}
              else
                records&.as_props || {}
              end
            }
            self.attribute(
              key,
              method:,
              to:,
              cast:,
              default:,
              if:,
            )
          end
        end

        # Propsに設定されるキーと値のペアを返します
        # @param 各種パラメータは self.attribute に合わせているためそちらを参照してください
        # @return [Hash] 設定されるPropsのキーと値のペア
        # @note memo
        #   if が予約語のため options として受け取っています。_ifも検討しましたが全体でキーワードの形を合わせたかったためoptionsの形にしています
        def attribute(key, method: nil, to: :model, cast: nil, default: NO_DEFAULT, **options)
          __build_props_attribute__(key, (method || key), to, cast, default, **options)
        end

        # 一度にまとめて複数のattributeを設定します
        # パラメータは self.attributes に合わせているためそちらを参照してください
        def attributes(*methods, to: :model, cast: nil, default: nil, **options)
          _props = {}
          methods.each do |method|
            key = method.to_sym
            unit_props = __build_props_attribute__(key, method, to, cast, default, **options)

            _props.merge!(unit_props)
          end

          # ブロックが渡されていれば実行する
          if block_given?
            _props = yield(_props)
          end

          # Classのマークをつける(テスト用)
          _props.merge!(__build_props_class_mark__)
          # Modelのマークをつける
          _props.merge!(__build_props_meta_mark__)

          _props
        end

        # @override
        #   Props::Base#as_props をオーバーライドしています
        #   本モジュールを読み込んだクラスではas_propsはオーバーライドせず、DSLとpropsメソッドを上書きしてください
        # @note 仕様
        #   クラス側で設定されたattribute, attributesを元にPropsを作成します
        #   もしくはオーバーライドされているであろう props の結果を設定します
        #   もし両方を設定しているときはどちらの値も設定されます
        #     キーがかぶっているときはprops側が優先されます
        # @return [Hash] props
        def as_props
          _props = {}

          # 結合先が指定されていればその結合先のpropsを取得する
          if self.class.union.present?
            if self.class.union == :default
              _props.merge!(model.as_props)
            else
              _props.merge!(model.as_props(self.class.union))
            end
          end

          # DSLの設定があればそれを設定する
          self.class.settings_attributes.to_a.each do |settings|
            _props.merge!(
              attribute(settings[:key], method: settings[:method], to: settings[:to], cast: settings[:cast], default: settings[:default], if: settings[:if])
            )
          end

          # Classのマークをつける(テスト用)
          _props.merge!(__build_props_class_mark__)
          # Modelのマークをつける
          _props.merge!(__build_props_meta_mark__)
          # Propsがオーバーライドされていればその値で上書きする
          _props.merge!(self.props)

          _props
        end

        # @return [Hash] props
        # @note
        # 　オーバーライドして使うことを想定しています
        def props
          {}
        end
      end

      private

      # @param [Array<Symbol>] methods
      # @param [Symbol] key
      # @param [Symbol] to メソッドのデリゲート先
      # @param [Block] blockを渡すと実行結果をブロック引数でわたし、その中の戻り値を結果として返します
      # @param [Symbol] cast デリゲート先のメソッドの戻り値に対して、さらにメソッドを実行する
      # 複雑性を増す代わりに集約をさせています
      def __build_props_attribute__(key, method, to, cast, default, **options)
        props = {}

        _if = options[:if]
        if _if.present?
          result = _if.is_a?(Proc) ? _if.call(model) : send(_if)
          return {} unless result
        end

        # javascriptは?をキーとして使えないので削除しつつ、isXxx形式に変換する
        if key.to_s.end_with?("?")
          key = key.to_s.gsub("?", "").to_sym
          key = "is_#{key}".to_sym unless key.start_with?("is_")
        end

        # valはこの後の工程で書き換えの可能性があるため注意
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

        case val
        when Date
          val = val.strftime(FORMATS[:date])
        when ActiveSupport::TimeWithZone, Time
          # 日付系であればjsで使えるようにhtmlに変換する
          val = val.strftime(FORMATS[:datetime])
        else
          if cast.present? && CAST_IGNORE_METHODS.exclude?(key)
            val = cast.to_s.split(".").inject(val) do |lval, cast_method|
              lval.send(cast_method)
            end
          end
        end

        if val.nil? && default != NO_DEFAULT
          val = default
        end

        props[key] = val

        props
      end

      # テストモードのときはどのPropsを実行したかを判定できるように属性をつけたします
      def __build_props_class_mark__
        mark = {}
        if ENV["RAILS_ENV"] == "test"
          mark[:props_class_name] = self.class.name
          if self.class.union.present?
            mark[:union_type_name] = self.class.union
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
  end
end
