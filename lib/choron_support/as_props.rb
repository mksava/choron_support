require_relative "props/base"
require_relative "props/attributes"
require_relative "props/ext/relation"
require_relative "props/ext/hash"
module ChoronSupport
  module AsProps
    class NameError < StandardError; end
    # @param [Symbol, String, nil] type_symbol どのPropsクラスを利用してPropsを生成するかを指定するシンボル。nilのときはデフォルトのPropsクラスを利用する。
    # @param [Hash] params その他のパラメータ。camel: false を指定すると自動でキャメライズしない。
    # @return [Hash]
    def as_props(type_symbol = nil, **params)
      serializer = self.__get_props_class(type_symbol, params)

      skip_camel = (params[:camel] == false)
      pass_params = params.except(:camel)
      if serializer.nil?
        skip_camel ? self.as_json : self.as_json.as_camel
      else
        skip_camel ? serializer.as_props(**pass_params) : serializer.as_props(**pass_params).as_camel
      end
    end

    private

    def __get_props_class(type_symbol, params)
      case type_symbol
      when Symbol, String
        # 名前空間の例: Serialize::Users
        namespace = "Props::#{self.class.to_s.pluralize}"
        # クラス名の例: :foo_bar => FooBar
        class_name = type_symbol.to_s.classify
        # 例: Serialize::Users::FooBar
        props_class_name = "#{namespace}::#{class_name}"
      when nil
        namespace = "Props"
        # 例: User / Master::Plan
        class_name = self.class.to_s
        # 例: Props::User
        props_class_name = "#{namespace}::#{class_name}"
      else
        raise ArgumentError
      end

      begin
        props_class = props_class_name.constantize

        props_class.new(self, params)
      rescue *rescue_errors
        # もしmodelを指定しているときはnilを返し、as_jsonを利用させる
        if type_symbol == :model
          return nil
        end

        if type_symbol.blank?
          raise ChoronSupport::AsProps::NameError, "Props class not found: #{props_class_name}. Please create props class."
        else
          raise ChoronSupport::AsProps::NameError, "Props class not found: #{props_class_name}. Got type symbol: #{type_symbol}."
        end
      end
    end

    def rescue_errors
      if defined?(Zeitwerk)
        [::NameError, Zeitwerk::NameError]
      else
        [::NameError]
      end
    end
  end
end
