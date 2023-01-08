require_relative "domains/base"

module ChoronSupport
  module DomainDelegate
    extend ActiveSupport::Concern

    included do
      extend Forwardable

      # QueryオブジェクトパターンをEasyに使うためのクラスメソッドです
      # @param [Symbol] method_name Modelに定義されるメソッド名
      # @param [Choron::Domains::Base] option domain Domainクラスを直接指定することができます。デフォルトはnilです。
      # @param [Symbol] option domain_to_method 委譲先のDomainクラスの呼び出しメソッドを指定できます。デフォルトは :call です
      # @exampl
      #   class User < ApplicationRecord
      #     domain_delegate :purchase
      #     #=>
      #       def purchase(item)
      #         Domains::Users::Purchase.new(self).call(item)
      #       end
      #
      #     domain_delegate :purchase, specific: false
      #     #=>
      #       def run_get(item)
      #         Domains::Purchase.new(self).call(item)
      #       end
      #
      #     domain_delegate :purchase, specific: false, class_name: "Domains::Buy", to: :buy_user
      #     #=>
      #       def purchase(item)
      #         Domains::Buy.new(self).buy_user(item)
      #       end
      #   end
      def self.domain_delegate(method_symbol, specific: true, class_name: nil, to: :call)
        if class_name.present?
          domain_class = class_name.constantize
        else
          model_name = specific ? self.to_s : nil
          # 例: Domains::Users::Purchase
          domain_class = ChoronSupport::Helper.generate_choron_class("Domains", model_name, method_symbol)
        end

        # 被ることがないようにど__をつけてメソッド名を定義します
        # 例: :__domains_users_purchase_object__
        domain_object_method_name = ("__" + domain_class.to_s.underscore.gsub("/", "_") + "_object__").to_sym

        define_method(domain_object_method_name) do
          # ドメインオブジェクトをインスタンス化したものを返します
          # このインスタンスに対して後述でデリゲートさせています
          # 例: Domains::Users::Purchase.new(self)
          domain_class.new(self)
        end
        self.instance_eval { private domain_object_method_name }

        # ドメインオブジェクトにデリゲートさせます
        # 例: def_delegator :__domains_users_purchase_object__, :call, :purchase
        #    purchase メソッドを __domains_xxx__ の call メソッドにデリゲートする
        def_delegator domain_object_method_name, to, method_symbol
      end
    end
  end
end