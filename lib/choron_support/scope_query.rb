require_relative "queries/base"
module ChoronSupport
  module ScopeQuery
    extend ActiveSupport::Concern

    included do
      # QueryオブジェクトパターンをEasyに使うためのクラスメソッドです
      # @param [Symbol, String] ActiveRecordの .scope に渡す第一引数
      # @param [Boolean] option specific Queryクラスの配置箇所の指定に関わるパラメータ。デフォルトtrue。falseのときは名前空間を Queries:: だけにし、trueのときは Queries::{クラス名の複数形}:: にします
      # @param [Choron::Queries::Base] q 直接Queryクラスを指定したいときはこちらにパラメータで渡してください
      # @example
      #   class User < ApplicationRecord
      #     query_scope :not_logined
      #     #=> scope :not_logined, Queries::Users::NotLogined.new(self)
      #   end

      def self.scope_query(query, specific: true, class_name: nil)
        # 直接Queryクラスを指定されていたらすぐにscopeにプロキシして返す
        if !class_name.to_s.empty?
          query_class = class_name.to_s.constantize
        else
          namespace = "Queries"
          model_name = specific ? self.to_s : nil
          query_class = ChoronSupport::Helper.generate_choron_class(namespace, model_name, query)
        end

        # ActiveRecordのscopeメソッドを呼びます
        scope(query.to_sym, query_class.new(self))
      end
    end
  end
end