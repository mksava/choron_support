module Queries
  module Users
    class ByName < ChoronSupport::Queries::Base
      def call(name)
        records.where(name: name)
      end
    end
  end
end