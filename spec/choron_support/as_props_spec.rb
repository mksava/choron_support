# AsPropsの使い方およびテスト用ファイルです。
# その他の多数のjson変換ツールとの違いとしては以下です
#   1.jsonのキーをローキャルケースにデフォルトで変換します
#   2.リッチな機能は提供せず、あくまでもクラスに委譲させるだけの責務を持っています
#     例えば他のgemにあるような attribute というようなDSLの機能はありません
#     全ては as_props に委譲されます
RSpec.describe ChoronSupport::AsProps do
  # as_props はモデルのインスタンスをjsonに変換します。
  # [使い方]
  # ActiveRecord等のモデルに対して以下のように設定を行ってください
  # class Foo < ApplicationRecord
  #   include ChoronSupport::AsProps
  # end
  #
  # そして以下のルールでJSON変換用のクラスを作成してください
  #   app/models/props/${モデル名}.rb
  #   例: app/models/props/foo.rb
  # これにより as_props を使うと上記のクラスの内容に従ってJSONの変換を行います
  #
  # このときのpropsクラスは以下のルールで作成してください
  #   1.ChoronSupport::Props::Baseを継承する
  #   2.as_props というメソッドを作成する
  #     => この戻り値が最終的に返されるjsonになります
  # [例] app/models/props/foo.rb
  #   class Props::Foo < ChoronSupport::Props::Base
  #     def as_props
  #       {
  #          id: model.id,
  #          name: model.name,
  #       }
  #     end
  describe "#as_props" do
    # ここでは PropsUser というモデルがあることとして使い方を記載しています。
    # 実際のモデルは app/models/props_user.rb を参照してください。
    describe PropsUser do
      # 各値が設定されたインスタンスがあります。
      let!(:user) { build(:props_user, id: 10, name: "cat", email: "mail@example.com") }
      # as_props は引数を受け取れますが、まずは引数を受け取らないときの説明を行います
      context "第一引数を渡さないとき" do
        it "app/models/props/props_user.rbで生成されるjsonが取得できること" do
          # 以下のように変換を利用します
          props = user.as_props
          # 結果はこのようになります
          # 実際に変換の中身は app/props/props_user.rb を参照してください。
          expect(props).to eq({ id: 10, name: "cat", email: "mail@example.com" })
        end
      end

      # as_props に引数を渡すと、変換を行うクラスを変更することができます。
      # このときは以下のようなルールになります
      #   foo.as_props(:bar)
      #   => app/models/props/foos/bar.rb で変換が行われる
      # これによりどのようなjsonに変換するかを複数のクラスで表現することができます
      # ※これは本Gemの思想につながっています。if文を使わずにクラスで責務を表現しています
      context "as_propsの第一引数に :compare を渡したとき" do
        it "app/models/props/props_users/compare.rbで生成されるjsonが取得できること" do
          # 以下のように変換を利用します
          props = user.as_props(:compare)
          # 結果はこのようになります
          # 実際に変換の中身は app/props/props_users/compare.rb を参照してください。
          expect(props).to eq({ userId: 10, compareSpec: "compare", comment: "hello" })
        end
      end

      # as_propsを使用するときには、キーワード引数でパラメータを渡すことも可能です。
      # これによりクラスによる責務と引数による微調整も可能です。
      context "as_propsの第一引数に :compare を渡し、キーワード引数も渡すとき" do
        it "app/models/props/props_users/compare.rbで生成されるjsonが取得できること" do
          # 以下のように変換を利用します
          props = user.as_props(:compare, comment: "spec")

          # 結果はこのようになります
          # 実際に変換の中身は app/props/props_users/compare.rb を参照してください。
          expect(props).to eq({ userId: 10, compareSpec: "compare", comment: "spec" })
        end
      end

      # もしローキャメルケースの変換を行いたくない場合は、キーワード引数で camel: false を指定してください
      context "as_propsの第一引数に :compare を渡し、キーワード引数で camel: false を渡すとき" do
        it "app/models/props/props_users/compare.rbで生成されるjsonがスネークケースで取得できること" do
          # 以下のように変換を利用します
          props = user.as_props(:compare, camel: false)

          # 結果はこのようになります
          # 実際に変換の中身は app/props/props_users/compare.rb を参照してください。
          expect(props).to eq({ user_id: 10, compare_spec: "compare", comment: "hello" })
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

    # その他の便利な機能の説明のためもう1つモデルを使って説明を記載します
    describe PropsComment do
      let!(:comment) { build(:props_comment, id: 10, title: "hello", body: "world") }
      # app/props にクラスを作成せずに、jsonの変換を使うこともできます
      # そのときは as_props の第一引数に :model を渡してください
      context "as_propsの第一引数に:modelを渡すとき" do
        # このときは ActiveRecord#as_json の結果をローキャメルケースに変換した結果を返します
        # @注意
        #   便利ではありますが基本全ての項目がjsonになり、ユーザには見えてはいけない値もjsonになる可能性もあります
        #   利用時は上記の点に注意してください。
        it "ActiveRecord#as_json の結果をローキャメルケースに変換した結果が返ること" do
          props = comment.as_props(:model)
          expect(props).to eq({ id: 10, title: "hello", body: "world", userId: nil, createdAt: nil, updatedAt: nil })
        end
      end
    end
  end

  # as_props はモデルだけではなく ActiveRecord::Relation にも使うことができます。
  # 特に使うときはクラスの型を意識する必要はありません。
  # Railsの持つas_jsonと同じように使ってください
  describe ActiveRecord::Relation do
    before do
      create(:props_user, id: 1, name: "cat", email: "mail1@example.com")
      create(:props_user, id: 2, name: "dog", email: "mail2@example.com")
    end
    describe "#as_props" do
      context "第一引数を渡さないとき" do
        it do
          props = PropsUser.all.as_props
          expect(props.size).to eq 2
          expect(props[0]).to eq({ id: 1, name: "cat", email: "mail1@example.com" })
          expect(props[1]).to eq({ id: 2, name: "dog", email: "mail2@example.com" })
        end
      end

      context "第一引数に :compare を渡すとき" do
        context "キーワード引数は渡さないとき" do
          it do
            props = PropsUser.all.as_props(:compare)
            expect(props.size).to eq 2
            expect(props[0]).to eq({ userId: 1, compareSpec: "compare", comment: "hello" })
            expect(props[1]).to eq({ userId: 2, compareSpec: "compare", comment: "hello" })
          end
        end

        context "キーワード引数を渡すとき" do
          it do
            props = PropsUser.all.as_props(:compare, camel: true, comment: "spec")
            expect(props.size).to eq 2
            expect(props[0]).to eq({ userId: 1, compareSpec: "compare", comment: "spec" })
            expect(props[1]).to eq({ userId: 2, compareSpec: "compare", comment: "spec" })
          end
        end

        context "キーワード引数を渡し、かつローキャメルケースの変換を行わないとき" do
          it do
            props = PropsUser.all.as_props(:compare, camel: false, comment: "spec")
            expect(props.size).to eq 2
            expect(props[0]).to eq({ user_id: 1, compare_spec: "compare", comment: "spec" })
            expect(props[1]).to eq({ user_id: 2, compare_spec: "compare", comment: "spec" })
          end
        end
      end
    end
  end
end