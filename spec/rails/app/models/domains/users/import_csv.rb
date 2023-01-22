module Domains
  module Users
    class ImportCsv < ChoronSupport::Domains::Base
      def call(csv_strings, format:)
        "csv_string: #{csv_strings}. format: #{format}."
      end
    end
  end
end