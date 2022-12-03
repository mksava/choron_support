module Domains
  class Hit < ChoronSupport::Domains::Base
    def call(name)
      "Hit #{name}!"
    end
  end
end