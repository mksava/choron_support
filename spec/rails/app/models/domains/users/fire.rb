module Domains
  module Users
    class Fire < ChoronSupport::Domains::Base
      def call
        "fire"
      end
    end
  end
end