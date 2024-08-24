module ChoronSupport
  module Queries
    class Base
      # @param [ActiveRecord::Base] model_class
      def initialize(model_class)
        @model_class = model_class
        @records = model_class.try!(:all)
      end

      # 各種このメソッドをオーバーライドしてください
      def call
        raise NotImplementedError
        # @example 実装例
        #   recordsにはscopeが呼び出された瞬間にチェインされてきたSQL情報が入ったActiveRecord::Relationが入っているため、そのままwhereを繋げていけば良い
        #   records.where(xxx: foo)
      end

      private

      attr_reader :model_class, :records

      # 以下、共通的に使えそうな便利メソッドたちです

      # 渡された文字列をLike文用にサニタイズして返します
      # @param [String]
      # @return [String]
      def like_sanitize(string)
        str = string.to_s
        return "" if str.empty?

        ApplicationRecord.sanitize_sql_like(str)
      end
    end
  end
end