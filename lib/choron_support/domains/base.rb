module ChoronSupport
  module Domains
    class Base
      # @param [ActiveRecord::Base] model
      def initialize(model)
        @model = model

        # Modelにアクセスするためのメソッドを作成する
        # Userであれば user, UserFeedBack であれば user_feed_back というように単数系スネークケースでアクセス可能にする
        model_method_name = model.class.to_s.underscore
        self.define_singleton_method(model_method_name) do
          @model
        end
      end

      # 各種このメソッドをオーバーライドしてください
      def call
        raise NotImplementedError
      end

      private

      attr_reader :model
    end
  end
end