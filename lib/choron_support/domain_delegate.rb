require_relative "domains/base"

module ChoronSupport
  module DomainDelegate
    extend ActiveSupport::Concern

    included do
      extend Forwardable

      # QueryオブジェクトパターンをEasyに使うためのクラスメソッドです
      # @param [Symbol] method_name Modelに定義されるメソッド名
      # @param [Choron::Domains::Base] option domain Domainクラスを文字列で直接指定することができます。シンボルを渡すとクラス化を自動で行います。デフォルトはnilです。
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
        domain_class = __generate_choron_domain_class(method_symbol, specific, class_name)

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

      # domain_delegate とほぼ同じ動きですが、こちらはクラスメソッドをデリゲートするものです。
      # パラメータも同じなのでここでは説明を省略します
      # @example
      #   class User < ApplicationRecord
      #     class_domain_delegate :import_csv
      #     #=>
      #       def self.import_csv
      #         Domains::Users::ImportCsv.new(self).call
      #       end
      #
      #     class_domain_delegate :import_csv, specfic: false
      #     #=>
      #       def self.import_csv(csv_strings)
      #         # 細かいことは省略しますが引数もちゃんとデリゲートできるようにしています
      #         Domains::ImportCsv.new(self).call(csv_strings)
      #       end
      #
      #     class_domain_delegate :import_csv, class_name: :manage_csv, to: :import
      #     #=>
      #       def self.import_csv
      #         Domains::Users::ManageCsv.new(self).import
      #       end
      def self.class_domain_delegate(method_symbol, specific: true, class_name: nil, to: :call)
        domain_class = __generate_choron_domain_class(method_symbol, specific, class_name)

        # どのような引数でもデリゲートできるようにしています
        define_singleton_method(method_symbol) do |*params, **keyparams|
          case [!params.empty?, !keyparams.empty?]
          when [true, true]
            domain_class.new(self).send(to, *params, **keyparams)
          when [true, false]
            domain_class.new(self).send(to, *params)
          when [false, true]
            domain_class.new(self).send(to, **keyparams)
          else
            domain_class.new(self).send(to)
          end
        end
      end

      private

      def self.__generate_choron_domain_class(method_symbol, specific, class_name)
        # クラス名指定なしのときはメソッド名からクラスを推測する
        if class_name.to_s.empty?
          model_name = specific ? self.to_s : nil
          # @example
          #   xxx_delegate :purchase
          #   => Domains::Users::Purchase
          #   xxx_delegate :purchase, specfic: false
          #   => Domains::Purchase
          return ChoronSupport::Helper.generate_choron_class("Domains", model_name, method_symbol)
        end

        if class_name.is_a?(Symbol)
          # クラス名がシンボルで渡されているときは、シンボル値からクラス名を推測する
          model_name = specific ? self.to_s : nil
          # @example
          #   xxx_delegate :purchase, class_name: :paymanet
          #   => Domains::Users::Payment
          #   xxx_delegate :purchase, class_name: :payment, specifix: false
          #   => Domains::Payment
          ChoronSupport::Helper.generate_choron_class("Domains", model_name, class_name)
        else
          # それ以外のときは直接クラスにする
          # @example
          #  xxx_delegate :purchase, class_name: "Domains::Payment"
          #  => Domains::Payment
          class_name.constantize
        end
      end
    end
  end
end