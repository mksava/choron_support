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

# @file app/models/props/props_comments/re_general.rb
class Props::PropsComments::ReGeneral < Props::Base
  attribute :id
end

# @file app/models/props/props_users/re_general.rb
class Props::PropsUsers::ReGeneral < Props::Base
  # 通常の使い方。
  #   第一引数: modelに実行するメソッド。通常はhas_manyなどの関連を指定する
  #   第二引数: Props化をするためのPropsクラス
  # { propsComments: model.props_comments.as_props(:general) }
  relation :props_comments, Props::PropsComments::General

  # name オプションでキー名を指定することができる
  # { comments: model.props_comments.as_props(:general) }
  relation :props_comments, Props::PropsComments::General, name: :comments

  # それ以外も基本的に attribute と同じオプションを指定してカスタマイズできます

  # 無理してDSLで表現せずにメソッドを使うことも考えてください
  attribute :easy_comments, to: :self
  def easy_comments
    model.props_comments.map do |comment|
      {
        title: comment.title,
      }
    end
  end
end

RSpec.describe "[relationの一般的な使い方]" do
  let!(:user) { create(:props_user, id: 10, name: "cat", email: "mail@example.com", weight: nil, is_super_man: false, created_at: "2023/12/10 13:00:00") }
  let!(:comment1) { create(:props_comment, id: 20, title: "title1", body: "body1", user_id: user.id) }
  let!(:comment2) { create(:props_comment, id: 21, title: "title2", body: "body2", user_id: user.id) }
  context "as_propsの第一引数に :general を渡したとき" do
    it "Props::PropsUsers::Generalで生成されるjsonが取得できること" do
      props = user.as_props(:re_general)
      aggregate_failures do
        props_comments = props[:propsComments]
        expect(props_comments.size).to eq 2

        comments = props[:comments]
        expect(comments.size).to eq 2

        easy_comments = props[:easyComments]
        expect(easy_comments.size).to eq 2
      end
    end
  end
end
