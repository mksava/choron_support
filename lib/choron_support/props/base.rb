# 本クラスはChoronSupportを利用しているRailsで継承されることを想定して作成されてます
# Choronでは以下のようにBaseクラスがデフォルトで作成されています
# @example
#   [app/models/props/base.rb]
#   class Props::Base < ChoronSupport::Props::Base
#     include ChoronSupport::Props::Attributes
#   end
# そして各種モデルのPropsは上記のBaseクラスを継承して作成されています
# @example
#   [app/models/props/user.rb]
#   class Props::User < Props::Base
#     attributes :id, :name, :age
#   end
#   [app/models/props/users/secure.rb]
#   class Props::Users::Secure < Props::Base
#     # secure側はageは非表示
#     attributes :id, :name
#   end
module ChoronSupport
  module Props
    class Base
      # @param [ActiveRecord::Base] model Props対象のモデルのインスタンス
      # @param [Hash] params その他のパラメータ
      def initialize(model, params = {})
        @model = model
        @params = params
      end

      # 継承先で実装されることを想定しています
      # ChoronSupport::Props::Attributes を読み込んでいるときは、そちらでオーバーライドされています
      def as_props
        raise NotImplementedError
      end

      private

      attr_reader :model, :params
    end
  end
end
