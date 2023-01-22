module Domains
  module Users
    class AgeManage < ChoronSupport::Domains::Base
      def create
        "create age"
      end

      def destroy
        "destroy age"
      end
    end
  end
end