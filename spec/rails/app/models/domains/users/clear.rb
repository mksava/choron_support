module Domains
  module Users
    class Clear < ChoronSupport::Domains::Base
      def call(target:)
        "Clear #{target}!"
      end

      def hello
        "hello clear"
      end

      def spec1(arg)
        "spec1 #{arg}"
      end

      def spec2(arg:)
        "spec2 #{arg}"
      end
    end
  end
end