## Model層 ###############################################################
# @file app/models/props_user.rb
class PropsUser < ApplicationRecord
  include ChoronSupport::AsProps

  def super_man?
    self.is_super_man?
  end
end

## Props層 ###############################################################
module Props; end
module Props::PropsUsers; end

# @file app/models/props/base.rb
class Props::Base < ChoronSupport::Props::Base
end

# @file app/models/props/props_users/in_general.rb
class Props::PropsUsers::InGeneral < Props::Base
  attribute :id
  attribute :test_name do
    "test"
  end

  attribute :full_name do
    "FullName"
  end
  attribute :spec1, to: :self
  def spec1
    "Spec1"
  end
end

# @file app/models/props/props_users/in_foo.rb
class Props::PropsUsers::InFoo < Props::Base
  # 使い方
  #   第一引数: 設定を引き継ぎたいPropsクラス
  inherit Props::PropsUsers::InGeneral

  attribute :email

  # 上書きできる
  attribute :full_name do
    "Overridden FullName"
  end

  # メソッドを再定義することで上書きができる
  # @override
  def spec1
    "Over Spec1"
  end
end

RSpec.describe "[attributeの一般的な使い方]" do
  let!(:user) { create(:props_user, id: 10, name: "cat", email: "mail@example.com", weight: nil, is_super_man: false, created_at: "2023/12/10 13:00:00") }
  context "as_propsの第一引数に :general を渡したとき" do
    it "Props::PropsUsers::Generalで生成されるjsonが取得できること" do
      props = user.as_props(:in_foo)
      aggregate_failures do
        expect(props[:id]).to eq 10
        expect(props[:testName]).to eq "test"
        expect(props[:fullName]).to eq "Overridden FullName"
        expect(props[:spec1]).to eq "Over Spec1"
      end
    end
  end
end
