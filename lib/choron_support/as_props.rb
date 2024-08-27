require_relative "props/base"
require_relative "props/attributes"
require_relative "props/ext/relation"
require_relative "props/ext/hash"
module ChoronSupport
  module AsProps
    class NameError < StandardError; end

    # @param [Symbol, String, nil] type_symbol どのPropsクラスを利用してPropsを生成するかを指定するシンボル。nilのときはデフォルトのPropsクラスを利用する。
    # @param [Hash] params その他のパラメータ
    # @param [Hash] params params[:camel] false を指定すると自動でキャメライズしない。
    # @param [Hash] params params[:only] 指定した属性のみを出力します
    # @param [Hash] params params[:except] 指定した属性を出力しません
    # @param [Hash] params params[:sti] true を指定すると継承クラスのPropsを利用する
    # @return [Hash]
    def as_props(type_symbol = nil, **params)
      pass_params = params.except(:camel, :sti)

      serializer = __get_props_class(type_symbol, pass_params, sti: params[:sti])
      skip_camel = (params[:camel] == false)
      if serializer.nil?
        skip_camel ? as_json : as_json.as_camel
      else
        skip_camel ? serializer.as_props : serializer.as_props.as_camel
      end
    end

    private

    def __get_props_class(type_symbol, params, sti:)
      case type_symbol
      when Symbol, String
        model_namespace = if sti
                            # STIのときは継承クラスのPropsを利用する
                            self.class.superclass.to_s.pluralize
                          else
                            self.class.to_s.pluralize
                          end
        # 名前空間の例: Props::Users, Props::RealEstates::Buildings
        namespace = "Props::#{model_namespace}"
        # クラス名の例: :common => Common, :foo_bar => FooBar
        class_name = type_symbol.to_s.classify
        # 例: Props::Users::Common, Props::RealEstates::Buildings::FooBar
        props_class_name = "#{namespace}::#{class_name}"
      when Class
        # Classが渡されているときはそのまま利用する
        given_class = type_symbol
        unless given_class.method_defined?(:as_props)
          raise ArgumentError, "invalid class: #{given_class}, must be respond to :as_props. self: #{self.class}"
        end

        props_class_name = given_class.to_s
      else
        raise ArgumentError, "invalid type_symbol: #{type_symbol.inspect}. self: #{self.class}"
      end

      begin
        props_class = props_class_name.constantize

        props_class.new(self, params)
      rescue *rescue_errors
        if type_symbol.blank?
          raise ChoronSupport::AsProps::NameError,
                "Props class not found: #{props_class_name}. Please create props class. self: #{self.class}"
        else
          raise ChoronSupport::AsProps::NameError,
                "Props class not found: #{props_class_name}. Got type symbol: #{type_symbol}. self: #{self.class}"
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
