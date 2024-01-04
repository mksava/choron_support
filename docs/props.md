# Propsについて

## 概要
Propsは一言で言うとローキャメルケースのキーを持つJSON変換用のHashです。

Choronでは画面側の処理をReact + Typescrip の組み合わせで実現しています。
このときに、React側のProps(このpropsはReactの世界のpropsです)に、モデルの値や値クラスの値をJSON形式で渡す必要があります。

本モジュールのPropsは上記のReactへの値の受け渡しをサポートします。

一般的なJSON化ツールの違いとしては、Javascript側の記法・慣習を優先するため、
JSONのキーをローキャメルケース(fullName, isAdult,など)に自動変換します

## 使い方

```ruby
class Props::Samples::Foo < Props::Base
  attribute :id
  attribute :full_name
end

sample = Sample.new(id: 100, full_name: "mksava")
sample.as_props(:foo)
#=> { id: 100, fullName: "mksava", type: "Foo", modelName: "Foo" }
```

* 詳細な使い方はテストファイルを参照ください。
  * [一般的な使い方](../spec/choron_support/as_props/general_spec.rb)
  * [エッジケース](../spec/choron_support/as_props/edge_spec.rb)
  * [attribute DSLの使い方](../spec/choron_support/as_props/attribute_spec.rb)
  * [inherit DSL の使い方](../spec/choron_support/as_props/inherit_spec.rb)
  * [relation DSLの使い方](../spec/choron_support/as_props/relation_spec.rb)
* 実装は以下を参照ください
  * [as_props.rb](../lib/choron_support/as_props.rb)
  * [props/](../lib/choron_support/props/)