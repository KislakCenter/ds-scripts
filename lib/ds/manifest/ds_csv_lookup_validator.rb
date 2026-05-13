# frozen_string_literal: true

module DS
  module Manifest
    class DsCsvLookupValidator < BaseLookupValidator

      def locate_record source_path, lookup_value, lookup_value_location
        locator = DS::Extractor::CsvRecordLocator.new
        csv = source.load_source source_path
        csv.rewind
        locator.locate_record csv, lookup_value, lookup_value_location
      end
    end
  end
end
