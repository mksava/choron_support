module Queries
  class LimitTo < ChoronSupport::Queries::Base
    def call(num)
      records.limit(num)
    end
  end
end