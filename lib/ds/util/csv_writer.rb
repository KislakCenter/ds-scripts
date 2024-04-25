# frozen_string_literal: true

module DS
  module Util
    class CSVWriter
      attr_reader :headers
      attr_reader :outfile

      def initialize outfile:, headers: []
       @headers = headers
        @outfile = outfile
      end

      def write *rows
        rows.each do |row|
          csv << row
        end
      end

      def csv
        return @csv if @csv.present?
        @csv = CSV.open outfile, 'w+', headers: true
        @csv
      end

      def close
        @csv.close if @csv.present?
      end
    end
  end
end
