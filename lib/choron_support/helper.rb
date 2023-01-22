# frozen_string_literal: true

module ChoronSupport
  module Helper
    class << self
      def generate_choron_class(namespaces, model_name, class_symbol, exception: true)
        # 命名規則に従いQueryクラスを自動で探して scope を設定する
        namespace = begin
          if namespaces.is_a?(Array)
            namespaces.join("::")
          else
            namespaces.to_s
          end
        end

        unless model_name.to_s.empty?
          namespace = "#{namespaces}::#{model_name.pluralize}"
        end

        target_class_name = "#{namespace}::#{class_symbol.to_s.camelize}"
        # ? 終わりはクラスに変換できないため
        if target_class_name.end_with?("?")
          target_class_name.chop!
        end

        # 例: Queries::Users::NotLogined
        target_class = nil
        begin
          target_class = target_class_name.constantize
        rescue NameError => e
          if exception
            raise e
          end
        end

        target_class
      end
    end
  end
end
