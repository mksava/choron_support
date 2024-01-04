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

### Props

* [Props ドキュメント](./docs/props.md)を参照ください

### Mask

モデルに対してマスク処理をかけ、セキュリティを強くするための仕組みです。

* 詳細な使い方は [テストファイル](./spec/choron_support/set_mask_for_spec.rb) を参照ください。
* 詳細な実装は [こちら](./lib/choron_support/set_mask_for.rb) です。

### Domain

モデルの処理をメソッド単位で別クラスに委譲するための仕組みです。
クラスメソッド、インスタンスメソッドの両方で利用できます。

* 詳細な実装と使い方は [こちら](./lib/choron_support/domain_delegate.rb) を確認してください。

### Forms

ControllerでFormクラスのインスタンスを簡単に生成するための仕組みです。

* 詳細な実装と使い方はいかを参照してください。
  * [build_form](./lib/choron_support/build_form.rb)
    * ControllerからFormクラスのインスタンスを簡単に生成するメソッドです
  * [ChoronSupport::Forms::Base](lib/choron_support/forms/base.rb)
    * Formクラスのベースとなるクラスです

### Query

モデルのscope処理を別クラスに異常するための仕組みです。
もともと存在する `queryパターン` を簡単に使えるようにしたものです。

* 詳細な実装と使い方は [こちら](./lib/choron_support/scope_query.rb) を確認してください。

## Develop

Dockerを起動することで開発環境が整います

* Docker Image の作成

```bash
make d-build
```

* Dockerコンテナの起動

```bash
make run
```

* コンテナ内部に入る

```bash
make web
```

* テスト用のDBおよびテーブルの作成

※Dockerコンテナ内部で実行してくださ

```bash
make spec-db-create
make spec-table-create
```

* RSpecの実行

```bash
bin/rspec spec
```

## 本Gemの思想

* [こちら](docs/idea.md)を参照ください

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
