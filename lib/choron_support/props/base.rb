module ChoronSupport
  module Props
    class Base
      def initialize(model)
        @model = model
      end

      def as_props
        raise NotImplementedError
      end

      private

      attr_reader :model
    end
  end
end