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

      def write rows=nil, &block
        if block_given?
          _write_with_block &block
        elsif rows.is_a? Enumerable
          _write_all rows
        else
          raise ""
        end
      end

      private
      def _write_with_block
        CSV.open outfile, 'w+', headers: true do |csv|
          csv << headers
          yield csv
        end
      end

      def _write_all rows
        CSV.open outfile, 'w+', headers: true do |csv|
          csv << headers
          rows.each do |row|
            csv << row
          end
        end
      end
    end
  end
end
