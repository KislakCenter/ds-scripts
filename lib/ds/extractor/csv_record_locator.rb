# frozen_string_literal: true

module DS
  module Extractor
    class CsvRecordLocator < DS::Extractor::BaseRecordLocator

      def locate_record csv, lookup_value, lookup_value_location
        csv.rewind
        csv.filter_map { |row| row if row[lookup_value_location] == lookup_value}
      end
    end
  end
end
