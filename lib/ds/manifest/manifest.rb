# frozen_string_literal: true

require 'csv'

module DS
  module Manifest
    class Manifest
      include Enumerable

      attr_reader :csv
      attr_reader :source_dir
      def initialize csv, source_dir
        @csv = get_csv_data csv
        raise ArgumentError, "Cannot find directory: '#{source_dir}'" unless Dir.exist? source_dir
        @source_dir = source_dir
      end

      def headers
        csv.first.headers
      end

      def get_csv_data csv
        case csv
        when IO
          CSV.parse csv, headers: true
        when StringIO
          CSV.parse csv, headers: true
        when CSV::Table
          csv
        when String
          CSV.parse File.open(csv, "r"), headers: true
        else
          raise ArgumentError, "Cannot process input as CSV: #{csv.inspect}"
        end
      end

      def each &block
        csv.each do |row|
          #&block
          yield DS:: Manifest::Entry.new row
        end
      end


    end
  end
end