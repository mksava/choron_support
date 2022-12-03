module Domains
  module Users
    class Purchase < ChoronSupport::Domains::Base
      def run
        "Purchase #{user.name}!"
      end
    end
  end
end