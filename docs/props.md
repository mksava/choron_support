# Propsについて

## 概要
Propsは一言で言うとローキャメルケースのキーを持つJSON変換用のHashです。

Choronでは画面側の処理をReact + Typescrip の組み合わせで実現しています。
このときに、React側のProps(このpropsはReactの世界のpropsです)に、モデルの値や値クラスの値をJSON形式で渡す必要があります。

本モジュールのPropsは上記のReactへの値の受け渡しをサポートします。

一般的なJSON化ツールの違いとしては、Javascript側の記法・慣習を優先するため、
JSONのキーをローキャメルケース(fullName, isAdult,など)に自動変換します

## Choronでの使い方

### 基本的な使い方

ChoronにはChoronSupportにある
* ChoronSupport::Props::Base
* ChoronSupport::Props::Attributes
の2つのクラス・モジュールを継承&includedしたProps用の基底クラスを用意しています。

```app/models/props/base.rb
class Props::Base < ChoronSupport::Props::Base
  include ChoronSupport::Props::Attributes
end
```

そして以下の命名ルールにより、モデルごとのPropsクラスを作成しています
* app/models/props/${モデル名}.rb
  * 例: app/models/props/user.rb
これは ChoronSupport::AsProps モジュールがモデル名から自動で props/**/*.rb を探し出してインスタンスを生成してくれる処理に由来します。

```app/models/props/user.rb
class Props::Foo < Props::Base
  attributes :id, :name, :full_name
  attributes :full_name, to: :self
  def full_name
    "#{model.first_name} #{model.last_name}"
  end
end
```

これで準備は完了です。
以下のようにController等で利用ができます

```app/controllers/users_controller.rb
class UsersController < ApplicationController
  def index
    users = User.all
    props = {
      users: users.as_props
    }

    render react_file(props: props)
  end

  def show
    user = User.find(params[:id])
    props = {
      user: user.as_props
    }

    render react_file(props: props)
  end
end
```

サンプルコードからわかるように `#as_props` というメソッドはモデルおよびRelationの両方で利用が可能なように拡張をしています。

この拡張を使うためには ChoronSupport::AsProps モジュールを ApplicationRecord にinclude する必要があります。

Choronではすでに実施済です。

```app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  include ChoronSupport::AsProps
end
```

もしPropsクラスをわざわざ作らず、モデルのカラムをそのまま全てローキャメルケースで出したい時もあると思います。そのときは

```
user.as_props(:model)
```

と第一引数で `:model` を渡すことで、カラム全てをprops化します。
※これは個人情報など思わぬ値も出力してしまう可能性もあるため、安全な処理にだけ使うことを推奨します

また、キーワード引数を使うことでパラメーターを渡すことも可能です。
これを利用すれば、Props側を利用する側から細かいPropsの出力調整ができます。

```app/models/props/foo.rb
class Props::Foo < Props::Base
  attributes :id, :name
  attributes :full_name, if: :show_name?
  def show_name?
    # #params で as_props 実行時のキーワード引数にアクセスができる
    params[:show_name].present?
  end
end
```

これは以下のように利用できます

```
foo = Foo.find(1)
foo.as_props(show_name: true)
```

また、この `DSL` を使うことで以下の情報がメタ情報として自動的に出力されます。
* type: Props化を行なったクラスの名前(名前空間あり)
* modelName: Props化を行なったモデルの名前(名前空間なし)

```app/models/props/foos/bar.rb
class Props::Foos::Bar < Props::Base
  attributes :id, :name
end
```

Foos::Bar.new.as_props
#=> { id: x, name: "xxx", type: "Foos::Bar", modelName: "Bar" }

もし `RAILS_ENV=test` のときはさらに Props化を行なったクラスもメタ情報として付与されます。

Foos::Bar.new.as_props
#=> { id: x, name: "xxx", type: "Foos::Bar", modelName: "Bar", propsClassName: "Props::Foos::Bar" }

このメタ情報を使うことでテストの簡略化も可能となります。

例えば Controller のテストを以下のように書くことができます。

```spec/requests/foos_controller_spec.rb
describe FoosController, type: :request do
  describe "GET /foos/:id" do
    let!(:id) { foo.id }
    let!(:foo) { create(:foo) }
    it "詳細画面が表示されること" do
      is_expected.to eq 200

      react = rendered_react("foo/show")
      props = react.props
      # 細かい値の設定はProps側の単体テストで担保しているため、ここでは使われているPropsのみ検証する
      expect(props[:foo][:propsClassName]).to eq "Props::Foos::Bar"
      # Choron では専用のマッチャーがあるため以下のように記載も可能
      expect(props[:foo]).to be_use_props(Props::Foos::Bar)
    end
  end
end
```

### DSLの細かい使い方
* ChoronSupport::Props::Attributesのソースコードを参照ください
  * https://github.com/mksava/choron_support/blob/main/lib/choron_support/props/attributes.rb

### Propsの設計思想
ChoronでのPropsはattributesのDSLでif文の指定が可能です。
そうでなくてもpropsメソッドをオーバーライドすることでさらに細かい調整が可能です。

しかしPropsの設計思想は「1つのPropsで複数のパターンのJSONを作成する」よりも「複数のパターンがある分、Propsクラスを作成する」にあります。

たとえば「User」には個人情報が含まれいるため、Propsの出力を制御したいときは

* 一般的な利用
  * `app/models/props/user.rb`
* スタッフなど個人情報にアクセス可能なユーザからの利用
  * `app/models/props/users/staff.rb`
* ログインしているユーザ自身が自分自身の情報を見たいときに利用
  * `app/models/props/users/current.rb`

というようにPropsクラスを複数作成することを検討してください。
このとき、各Propsクラスは以下のように `#as_props` の第一引数を指定することで利用できます

```
# app/models/props/users/general.rb
users = Users.all.as_props(:general)
# app/models/props/users/staff.rb
users = Users.all.as_props(:staff)
# app/models/props/users/current.rb
users = Users.all.as_props(:current)
```

## サンプルコード

* Props を作成するときはこのサンプルコードを優先的に参考にしてください
* Sample の部分は適宜作成したいモデル名に変更してください

### ActiveRecord

```app/models/sample.rb
class Sample < ApplicationRecord
end
```

```app/controllers/samples_controller.rb
class SamplesController < ApplicationController
  def index
    samples = Sample.all
    props = {
      samples: samples.as_props(:general)
    }

    render react_file(props: props)
  end
end
```

```app/models/props/sample.rb
class Props::Sample < Props::Base
  attributes :id, :name, :created_at, :updated_at
  attributes :is_sample?, to: :self

  def is_sample?
    true
  end
end
```

```app/models/props/samples/general.rb
class Props::Samples::Genral < Props::Base
  attributes :id, :created_at, :updated_at
  attributes :is_sample?, to: :self

  def is_sample?
    false
  end
end
```

```app/models/props/samples/staff.rb
class Props::Samples::Staff < Props::Base
  self.union = :default
  attributes :salary
end
```