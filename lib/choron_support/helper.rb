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

        if model_name.present?
          namespace = "#{namespaces}::#{model_name.pluralize}"
        end

        # 例: Queries::Users::NotLogined
        target_class = nil
        begin
          target_class = "#{namespace}::#{class_symbol.to_s.camelize}".constantize
        rescue => e
          if exception
            raise e
          end
        end

        target_class
      end
    end
  end
end
