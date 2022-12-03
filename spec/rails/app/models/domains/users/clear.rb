module Domains
  module Users
    class Clear < ChoronSupport::Domains::Base
      def call(target:)
        "Clear #{target}!"
      end
    end
  end
end