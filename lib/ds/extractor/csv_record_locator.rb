# frozen_string_literal: true

module DS
  module Extractor
    class CsvRecordLocator

      def locate_record csv, id, id_location
        csv.filter_map { |row| row if row[id_location] == id}
      end
    end
  end
end
