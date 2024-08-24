class ChoronSupport::Props::Private::Setting
  class Error < StandardError; end
  # デフォルト値を設定しない場合に使う値
  NO_DEFAULT = Object.new.freeze
  private_constant :NO_DEFAULT
  SETTING_ATTRIBUTES = %i[method name to cast default if block].freeze

  SETTING_ATTRIBUTES.each { |atr_name| attr_reader atr_name }

  def initialize(params)
    # 不正なオプションがあれば例外を発生させる
    if (params.keys - SETTING_ATTRIBUTES).present?
      raise Error,
            "invalid params: #{(params.keys - SETTING_ATTRIBUTES).join(', ')}, valid params are #{SETTING_ATTRIBUTES.join(', ')}"
    end

    @method = params[:method]
    @name = params[:name] || @method
    @to = params[:to] || :model
    @cast = params[:cast]
    @default = params[:default] || NO_DEFAULT
    @if = params[:if] || nil
    @block = params[:block] || nil

    check_params!
  end

  def set_default?
    default != NO_DEFAULT
  end

  private

  def check_params!
    raise Error, "name is required" if name.blank?
    return unless method.blank?

    raise Error, "method is required"
  end
end
