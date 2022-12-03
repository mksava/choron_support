module Domains
  module Users
    class Register < ChoronSupport::Domains::Base
      def call
        "Register!"
      end
    end
  end
end