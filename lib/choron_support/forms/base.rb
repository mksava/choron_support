module ChoronSupport
  module Forms
    class Base
      def initialize(params, current_user)
        @params = params
        @current_user = current_user
      end

      private

      attr_reader :params, :current_user
    end
  end
end
