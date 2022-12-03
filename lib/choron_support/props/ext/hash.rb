class Hash
  def as_camel
    self.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
  end

  def to_camel_json
    as_camel_json.to_json
  end
end