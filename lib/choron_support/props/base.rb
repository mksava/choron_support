require_relative "./attributes"

module ChoronSupport
  module Props
    class Base
      include ChoronSupport::Props::Attributes

      # @param [ActiveRecord::Base] model Props対象のモデルのインスタンス
      # @param [Hash] params その他のパラメータ
      # @param [Boolean] params params[:only] 指定した属性のみを出力します
      # @param [Boolean] params params[:except] 指定した属性を出力しません
      def initialize(model, params = {})
        @model = model
        @params = params.to_h
      end

      private

      # @override
      attr_reader :model

      # @override
      attr_reader :params
    end
  end
end
