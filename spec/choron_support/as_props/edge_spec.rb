## Model層 ###############################################################
# @file app/models/props_user.rb
class PropsUser < ApplicationRecord
  include ChoronSupport::AsProps
end

## Props層 ###############################################################
module Props; end
module Props::PropsUsers; end

# @file app/models/props/base.rb
class Props::Base < ChoronSupport::Props::Base
end

# @file app/models/props/props_users/edge_general.rb
class Props::PropsUsers::EdgeGeneral < Props::Base
  attribute :id
  attribute :full_name do
    "FullName"
  end
end

# @file app/models/props/props_users/edge_override.rb
class Props::PropsUsers::EdgeOverride < Props::Base
  def as_props
    {
      dummy: "dummy",
      over: params[:over],
    }
  end
end

RSpec.describe "[Propsの特殊な使い方]" do
  let!(:user) { build(:props_user, id: 10, name: "cat", email: "mail@example.com") }

  describe "[ローキャメルケースの変換を行いたくないケース]" do
    it do
      # もしローキャメルケースの変換を行いたくない場合は、キーワード引数で camel: false を指定してください
      props = user.as_props(:edge_general, camel: false)

      aggregate_failures do
        expect(props[:id]).to eq 10
        expect(props[:full_name]).to eq "FullName"
      end
    end
  end

  context "[DSLで表現するとかえって保守性が落ちるケース]" do
    it do
      # as_props 自体をオーバーライドすることで自由にjsonを作成することができます
      props = user.as_props(:edge_override, over: 200)

      aggregate_failures do
        expect(props[:dummy]).to eq "dummy"
        expect(props[:over]).to eq 200
      end
    end
  end
end
