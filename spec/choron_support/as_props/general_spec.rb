## Model層 ###############################################################

# @file app/models/props_user.rb
class PropsUser < ApplicationRecord
  include ChoronSupport::AsProps

  has_many :props_comments, dependent: :destroy, foreign_key: :user_id
end

# @file app/models/props_comment.rb
class PropsComment < ApplicationRecord
  include ChoronSupport::AsProps

  belongs_to :props_user, foreign_key: :user_id
end

## Props層 ###############################################################

module Props; end
module Props::PropsUsers; end
module Props::PropsComments; end

# @file app/models/props/base.rb
class Props::Base < ChoronSupport::Props::Base
end

# @file app/models/props/props_comments/general
class Props::PropsComments::General < Props::Base
  attribute :id
  attribute :title
  attribute :body
end

# @file app/models/props/props_users/general.rb
class Props::PropsUsers::General < Props::Base
  attribute :id
  attribute :name
  attribute :email

  relation :props_comments, Props::PropsComments::General
end

# @file app/models/props/props_users/staff.rb
class Props::PropsUsers::Staff < Props::Base
  attribute :id, name: :user_id
  attribute :staff_spec do
    "Staff!"
  end
  attribute :comment, to: :self

  private

  def comment
    params[:comment] || "Default Comment"
  end
end

################################################################################

RSpec.describe "[Propsの一般的な使い方]" do
  let!(:user) { create(:props_user, id: 10, name: "cat", email: "mail@example.com") }
  let!(:comment1) { create(:props_comment, id: 20, title: "title1", body: "body1", user_id: user.id) }
  let!(:comment2) { create(:props_comment, id: 21, title: "title2", body: "body2", user_id: user.id) }
  context "as_propsの第一引数に :general を渡したとき" do
    it "Props::PropsUsers::Generalで生成されるjsonが取得できること" do
      props = user.as_props(:general)
      aggregate_failures do
        expect(props[:id]).to eq 10
        expect(props[:name]).to eq "cat"
        expect(props[:email]).to eq "mail@example.com"

        # 関連先のPropsも生成されること
        expect(props[:propsComments].size).to eq 2
        expect(props[:propsComments][0][:id]).to eq 20
        expect(props[:propsComments][0][:title]).to eq "title1"
        expect(props[:propsComments][0][:body]).to eq "body1"
        expect(props[:propsComments][1][:id]).to eq 21
        expect(props[:propsComments][1][:title]).to eq "title2"
        expect(props[:propsComments][1][:body]).to eq "body2"
        # もし関連先のPropsが別で単体テストを実施済であれば以下のようにテストを書くと良いでしょう
        expect(props[:propsComments][0][:propsClassName]).to eq "Props::PropsComments::General"
      end

      aggregate_failures do
        expect(props[:modelName]).to eq "PropsUser"
        expect(props[:type]).to eq "PropsUser"
      end

      aggregate_failures do
        expect(props[:propsClassName]).to eq "Props::PropsUsers::General"
      end
    end

    it "ActiveRecord::Relationでも利用できること" do
      # ActiveRecord::Relationからも利用可能です。
      #   .all に対してas_propsを実行しているためこのときの戻り値は配列になります
      user_props = PropsUser.all.as_props(:general)

      props = user_props[0]
      # 細かい検証はスキップしています
      aggregate_failures do
        expect(props[:propsClassName]).to eq "Props::PropsUsers::General"
      end
    end
  end

  context "as_propsの第一引数に :staff を渡したとき" do
    it "Props::PropsUsers::Staffで生成されるjsonが取得できること" do
      props = user.as_props(:staff)

      aggregate_failures do
        expect(props[:userId]).to eq 10
        expect(props[:staffSpec]).to eq "Staff!"
        expect(props[:comment]).to eq "Default Comment"
      end

      aggregate_failures do
        expect(props[:modelName]).to eq "PropsUser"
        expect(props[:type]).to eq "PropsUser"
      end

      aggregate_failures do
        expect(props[:propsClassName]).to eq "Props::PropsUsers::Staff"
      end
    end

    it "ActiveRecord::Relationでも利用できること" do
      # ActiveRecord::Relationからも利用可能です。
      #   .all に対してas_propsを実行しているためこのときの戻り値は配列になります
      user_props = PropsUser.all.as_props(:staff)

      props = user_props[0]
      # 細かい検証はスキップしています
      aggregate_failures do
        expect(props[:propsClassName]).to eq "Props::PropsUsers::Staff"
      end
    end
  end

  context "as_propsの第一引数に :compare を渡し、キーワード引数も渡すとき" do
    it "Props::PropsUsers::Staffで生成されるjsonが取得できること" do
      props = user.as_props(:staff, comment: "spec")

      aggregate_failures do
        expect(props[:userId]).to eq 10
        expect(props[:staffSpec]).to eq "Staff!"
        expect(props[:comment]).to eq "spec"
      end
    end

    it "ActiveRecord::Relationでも利用できること" do
      # ActiveRecord::Relationからも利用可能です。
      #   .all に対してas_propsを実行しているためこのときの戻り値は配列になります
      user_props = PropsUser.all.as_props(:staff, comment: "spec")

      props = user_props[0]
      # 細かい検証はスキップしています
      aggregate_failures do
        expect(props[:propsClassName]).to eq "Props::PropsUsers::Staff"
        expect(props[:comment]).to eq "spec"
      end
    end
  end

  # もしローキャメルケースの変換を行いたくない場合は、キーワード引数で camel: false を指定してください
  context "as_propsの第一引数に :staff を渡し、キーワード引数で camel: false を渡すとき" do
    it "Props::PropsUsers::Staffで生成されるjsonがスネークケースで取得できること" do
      # 以下のように変換を利用します
      props = user.as_props(:staff, camel: false, comment: "camel!")

      aggregate_failures do
        expect(props[:user_id]).to eq 10
        expect(props[:staff_spec]).to eq "Staff!"
        expect(props[:comment]).to eq "camel!"
      end
    end
  end

  # もし変換対象のクラスが見つからないときはエラーが発生します。
  # エラーログを確認し適切な修正を行ってください
  context "as_propsの第一引数に存在しないクラス名を渡すとき" do
    it "エラーが発生すること" do
      expect{ user.as_props(:invalid) }.to raise_error(ChoronSupport::AsProps::NameError)
    end
  end
end
