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

# @file app/models/props/props_users/atr_general.rb
class Props::PropsUsers::AtrGeneral < Props::Base
  # 通常の使い方。基本はmodelに指定したキーのメソッドを実行した結果を出力する
  # { id: model.id }
  attribute :id
  # DateやTime系のオブジェクトはHTMLのform用にフォーマット文字列に自動で変換される
  # { createdAt: model.created_at.strftime("%Y-%m-%dT%H:%") }
  attribute :created_at
  # ?で終わるものは is_xxx という形のキーに自動で変換される
  # { is_super_man: model.super_man? }
  attribute :super_man?

  # name オプションでキー名を指定することができる
  # { user_id: model.id }
  attribute :id, name: :user_id

  # ブロックを渡すとブロックの戻り値が使われる
  # { full_name: "FullName" }
  attribute :full_name do
    "FullName"
  end

  # ブロックは2つ引数を受け取って使うことができる
  #   model: ActiveRecordのインスタンス
  #   params: as_props 実行時のキーワードパラメータ
  # { spec1: model.id * 100 }
  attribute :spec1 do |model, params|
    model.id * params[:count].to_i
  end

  # to オプションで model 以外をレシーバにすることができる
  # { spec3: "doon" }
  attribute :spec2, to: :data
  def data
    Struct.new(:spec2).new("doon")
  end

  # :self を to で指定すると、自分自身をレシーバにすることができる
  # { spec3: "hello" }
  attribute :spec3, to: :self
  def spec3
    "hello"
  end

  # if オプションでメソッド名を渡すと、その戻り値がtrueのときのみ属性を出力させることができる
  # { email: model.email } or { }
  attribute :email, if: :admin?
  def admin?
    params[:is_admin]
  end

  # デフォルト値を設定することができる
  # { weight: model.weight } or { weight: 50 }
  attribute :weight, default: 50
end

RSpec.describe "[attributeの一般的な使い方]" do
  let!(:user) { create(:props_user, id: 10, name: "cat", email: "mail@example.com", weight: nil, is_super_man: false, created_at: "2023/12/10 13:00:00") }
  context "as_propsの第一引数に :general を渡したとき" do
    it "Props::PropsUsers::AtrGeneralで生成されるjsonが取得できること" do
      props = user.as_props(:atr_general, is_admin: false, count: 100)
      aggregate_failures do
        expect(props[:id]).to eq 10
        expect(props[:createdAt]).to eq "2023-12-10T13:00"
        expect(props[:isSuperMan]).to eq false
        expect(props[:userId]).to eq 10
        expect(props[:fullName]).to eq "FullName"
        expect(props[:spec1]).to eq 1000
        expect(props[:spec2]).to eq "doon"
        expect(props[:spec3]).to eq "hello"
        expect(props[:email]).to eq nil
        expect(props[:weight]).to eq 50
      end
    end
  end
end
