require_relative "./attributes"

module ChoronSupport
  module Props
    class Base
      include ChoronSupport::Props::Attributes

      # @param [ActiveRecord::Base] model Props対象のモデルのインスタンス
      # @param [Hash] params その他のパラメータ
      def initialize(model, params = {})
        @model = model
        @params = params
      end

      private

      # @override
      def model
        @model
      end

      # @override
      def params
        @params
      end
    end
  end
end

__END__
abcd
