# Relationから直接as_propsを使えるようにコア拡張
class ActiveRecord::Relation
  def as_props(type_symbol = nil, **params)
    if records.nil?
      return {}
    end

    records.map {|record| record.as_props(type_symbol, **params) }
  end
end