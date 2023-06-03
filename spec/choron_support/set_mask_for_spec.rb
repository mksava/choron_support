# SetMaskForの使い方およびテスト用ファイルです。
RSpec.describe ChoronSupport::SetMaskFor do
  # SetMaskForはActiveRecordに対して、マスク処理を行う必要最低限のAPIを提供します。
  # よって、どういう条件のときにマスクを外すのか？といった細かい判定方法の責務はRails側で独自に実装してください。
  describe ".set_mask_for" do
    # set_mask_for は第一引数で渡されたシンボルのカラム・メソッドに対してマスク処理を行うようになります。
    # [使い方]
    # ActiveRecord等のモデルに対して以下のように設定を行ってください
    # class Foo < ApplicationRecord
    #   include ChoronSupport::SetMaskFor
    #   set_mask_for :name, :is_super_man, :weight, :height, :birth_date
    # end
    #
    # なお、本モジュールは set_mask_for を呼び出さない限り副作用はないため、素直にApplicationRecordにincludeをしていても問題ありません
    # class ApplicationRecord < ActiveRecord::Base
    #  include ChoronSupport::SetMaskFor
    # end
    describe MaskingUser do
      # ここでは MaskingUserモデルがあることとして使い方を説明していきます。
      # 設定を行っている実際のモデルは spec/rails/app/models/masking_user.rb を参照してください。
      # 今回の説明では以下のようなレコードが作成されていることとします。
      let!(:masking_user) do
        create(:masking_user,
          name: "mksava",
          is_super_man: true,
          weight: 70,
          height: 170.4,
          birth_date: Date.new(1990, 1, 1),
        )
      end
      shared_examples :masking_value do
        # マスク処理がされた状態であれば、各カラム・メソッドの値は以下のように取得されるようになります。
        it "got value is masking value" do
          # 元々の値が文字列のときは、アスタリスク4つの文字が固定で返されます。
          # 2023/06時点ではこの固定文字の変更はできません
          expect(masking_user.name).to eq("****")

          # もしもともとの値が文字列でない場合は、nilが返されます。
          # これはカラムの期待する型がマスクにより文字列に変換されてしまうことで思わぬ動きにならないためです。
          expect(masking_user.is_super_man).to eq(nil)
          expect(masking_user.weight).to eq(nil)
          expect(masking_user.height).to eq(nil)
          expect(masking_user.birth_date).to eq(nil)
        end
      end

      shared_examples :origin_value do
        # マスクが外れた状態では、以下のように元々の値が取得されるようになります。
        it "got value is origin value" do
          expect(masking_user.name).to eq("mksava")

          expect(masking_user.is_super_man).to eq(true)
          expect(masking_user.weight).to eq(70)
          expect(masking_user.height).to eq(170.4)
          expect(masking_user.birth_date).to eq(Date.new(1990, 1, 1))
        end
      end

      context "(when default(wear mask state))" do
        # マスク処理はデフォルトで有効になっています。
        it_behaves_like :masking_value
      end

      context "(when without mask)" do
        # 以下のメソッドを呼び出すことで、そのモデルのインスタンスはマスクが外れた状態になります。
        # マスクを外す条件に一致するときは以下のメソッドを使ってマスクを外してください。
        before { masking_user.danger_without_mask! }
        it_behaves_like :origin_value
      end

      context "(when wear mask after without mask)" do
        # マスクを外した後に再度 wear_mask を呼び出すことで、マスクを再度有効にすることができます。
        before do
          # 外す
          masking_user.danger_without_mask!
          # またつける
          masking_user.wear_mask
        end
        it_behaves_like :masking_value
      end

      context "(when without mask block)" do
        # without_mask メソッドにブロックを渡すことで、そのブロック内部でだけマスクが外れた状態にすることができます。
        # ※ブロックの第一引数はマスクが外れた状態のモデルのインスタンスが渡されます。
        # ブロックの処理が終わるとマスクがまた有効になるため、安全にマスクの着脱ができます。
        it "get origin value in block" do
          masking_user.without_mask do |user|
            # この中でだけマスク処理が外れる
            expect(user.name).to eq("mksava")
          end
          # ブロックを抜けた後なのでマスク状態になる
          expect(masking_user.name).to eq "****"
        end
      end

      describe "#danger_xxx" do
        # set_mask_for を使うと、
        # 第一引数で渡した元のカラム・メソッド名に対して `danger_without_mask_` というprefixがついたメソッドが各種定義されています。
        # これらは、マスク着脱に関係なく元の値を取得することができます。
        it "get origin values" do
          aggregate_failures do
            expect(masking_user.danger_without_mask_name).to eq("mksava")
            expect(masking_user.danger_without_mask_is_super_man).to eq(true)
            expect(masking_user.danger_without_mask_weight).to eq(70)
            expect(masking_user.danger_without_mask_height).to eq(170.4)
            expect(masking_user.danger_without_mask_birth_date).to eq(Date.new(1990, 1, 1))
          end
        end
      end
    end
  end
end

__END__

ここから下はTipsです。以下のような使い方ができる、ということを記載していきます。

## サンプル
* ユーザは自分自身が閲覧するとき、もしくは閲覧者が権限を持っているときのみマスク処理が外される

class User < ApplicationRecord
  include ChoronSupport::SetMaskFor
  set_mask_for :email, :phone_number
end

### 例1: メソッドを定義する

class User < ApplicationRecord
  def try_mask_off!(current_user)
    # 未ログインであればマスク処理をする
    return self.wear_mask if current_user.nil?

    if current_user.id == self.id || current_user.admin?
      self.danger_without_mask!
    else
      self.wear_mask
    end
  end
end

def show
  target_user = User.find(params(:id))
  target_user.try_mask_off!(current_user)

  # ログインしているユーザに応じてマスク処理の着脱が行われている状態になる
  target_user.name
end

## 例2: 常に暗黙的な解除を試みる
class User < ApplicationRecord
  # インスタンスが生成されるたびに、その直後にマスクの着脱を走らせる
  after_initialize :try_mask_off!

  private

  def try_mask_off!
    # CurrentAttributesで常に現在ログインするユーザ情報を取得できるようにしておく
    current_user = CurrentAttributes::CurrentUser.current_user

    # 未ログインであればマスク処理をする
    return self.wear_mask if current_user.nil?

    if current_user.id == self.id || current_user.admin?
      self.danger_without_mask!
    else
      self.wear_mask
    end
  end
end

def show
  # この時点で暗黙的に try_mask_off! が呼ばれている
  target_user = User.find(params(:id))

  # ログインしているユーザに応じてマスク処理の着脱が行われている状態になる
  target_user.name
end