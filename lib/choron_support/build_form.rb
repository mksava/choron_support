require_relative "forms/base"
module ChoronSupport
  module BuildForm
    extend ActiveSupport::Concern

    included do
      def build_form(type = "", form_params = nil)
        form_name = "#{type}_form"
        form_class_name = File.join(controller_path, form_name).classify
        form_class = form_class_name.constantize
        init_params = form_params || params

        form_class.new(init_params, current_user)
      end
    end
  end
end