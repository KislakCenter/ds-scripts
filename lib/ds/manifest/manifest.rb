# frozen_string_literal: true

require 'csv'

module DS
  module Manifest
    class Manifest
      include Enumerable

      attr_reader :csv
      attr_reader :source_dir

      def self.normalize_lookup value
        return '' if value.blank?
        value.to_s.downcase.strip.gsub %r{\W+}, ''
      end

      def initialize csv, source_dir
        @csv = get_csv_data csv
        raise ArgumentError, "Cannot find directory: '#{source_dir}'" unless Dir.exist? source_dir
        @source_dir = source_dir
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
        @csv.each &block
      end
    end
  end
end