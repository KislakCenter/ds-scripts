# frozen_string_literal: true

module DS
  module Manifest
    class DsCsvIdValidator < BaseIdValidator

      def locate_record source_path, id, id_location
        locator = DS::Extractor::CsvRecordLocator.new
        source = find_or_open_source source_path
        source.rewind
        locator.locate_record source, id, id_location
      end

      def open_source source_path
        CSV.open(source_path, headers: true)
      end
    end
  end
end
