# ChoronSupport

Choron Support は Rails に便利な機能をいくつか提供する、生産性を向上するためのGemです

## インストール

```bash
$ gem install choron_support
```

```Gemfile:ruby
gem "choron_support"
```

### Rails

* config/initializers/choron.rb を作成し以下のコードを記載してください


```config/initializers/choron.rb
ChoronSupport.using :all
```

## 使い方

* 必要に応じて各種モジュールをincludeすることで利用できます

### AsProps

* TODO

### Domain

* TODO

### Forms

* TODO

### Query

* TODO

## Develop

Dockerを起動することで開発環境が整います

* Docker Image の作成

```bash
make d-build
```

* Docker コンテナの起動

```bash
make run
```

* テスト用のDBおよびテーブルの作成 & RSpecの実行
  * spec/spec_helper.rb を開いて下記にあるDBの作成/Tableの作成のフラグを true に書き換えてから、テストを実行してください
    * `bin/rspec spec`


## 本Gemの思想

Railsにはこれまで多くのリファクタリング手法が、多くの人々から提案されてきました。
その中で本Gemは以下の思想をサポートするようにしています

* レイヤーを多く作らずにModelへ処理を凝集する
  * Railsがデフォルトで用意してくれている `controllers`, `models`, `views` といったレイヤーのみをできるだけ使い、独自のレイヤーを**あまり**追加しない
* Modelの見通しをよくするためにファイル内の処理を委譲させる
  * 委譲先のクラスはModel以外からは直接呼び出さない(必ずModelにpublicなメソッドを経由させる)

これによりドメインの知識をModelレイヤーに集めつつ、
中規模以上のシステムになってきた際のファットモデルによる問題を解消する取り組みを行います

### 具体的な取り組み

Modelの中で行われる処理の中でも、本Gemは以下の処理を簡易に別クラスへ委譲させます

* ビジネスロジック・ドメインロジック
* DBへのアクセス・取得
* データを表示するための加工(json化)


---

以下、TODO

---



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
