# frozen_string_literal: true

module DS
  module Manifest
    class DsCsvIdValidator < BaseIdValidator

      def locate_record source_path, id, id_location
        locator = DS::Extractor::CsvRecordLocator.new
        csv = source.load_source source_path
        csv.rewind
        locator.locate_record csv, id, id_location
      end
    end
  end
end
