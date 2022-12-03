module Queries
  module Users
    class ByEmail < ChoronSupport::Queries::Base
      def call(email)
        records.where(email: email)
      end
    end
  end
end