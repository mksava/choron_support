require_relative "props/base"
require_relative "props/ext/relation"
require_relative "props/ext/hash"
module ChoronSupport
  module AsProps
    def as_props(type_symbol = nil, **params)
      serializer = self.__get_props_class(type_symbol, **params)

      if serializer.nil?
          self.as_json
      else
        serializer.as_props(**params)
      end
    end

    private

    def __get_props_class(type_symbol, **params)
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

        props_class.new(self)
      rescue *rescue_errors
        return nil
      end
    end

    def rescue_errors
      if defined?(Zeitwerk)
        [NameError, Zeitwerk::NameError]
      else
        [NameError]
      end
    end
  end
end
