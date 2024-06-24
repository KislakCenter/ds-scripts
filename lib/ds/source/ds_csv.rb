# frozen_string_literal: true

module DS
  module Source
    class DSCSV < BaseSource

      TYPE = DS::Constants::DS_CSV

      # Opens a CSV file at the specified `source_file_path` and returns a CSV object.
      #
      # @param source_file_path [String] The path to the CSV file.
      # @return [CSV] A CSV object representing the opened CSV file.
      def open_source source_file_path
        CSV.open(source_file_path, 'r', headers: true)
      end
    end
  end
end
