# frozen_string_literal: true

require 'csv'

module DS
  module Manifest
    class Manifest
      include Enumerable


      attr_reader :csv
      attr_reader :source_dir

      ##
      # @param [CSV::Table,IO,StringIO,String] manifest_csv either a parse CSV,
      #   an IO instance, a StringIO, a String CSV or the manifest path
      # @param [String] dir the path the directory containing the
      #   source file(s); if +source_dir+ is +nil+; CSV must be a {File}
      #   instance or a path
      # @return [DS::Manifest::Manifest] a new Manifest instance
      def initialize manifest_csv, dir=nil
        @csv = get_csv_data manifest_csv
        @source_dir = get_source_dir manifest_csv, dir
      end

      ##
      # The headers from the parsed Manifest CSV.
      # @return [Array<String>]
      def headers
        csv.first.headers
      end



      ##
      # @yield [DS::Manifest::Entry] entry representation of the manifest row
      def each &block
        csv.each do |row|
          yield DS::Manifest::Entry.new row
        end
      end

      ##
      # Return the String path of the directory expected to contain the
      # source records. If +dir+ is defined a directory, return +dir+.
      # Otherwise, if +manifest_csv+ is a String path or File object,
      # return its parent directory.
      #
      # @param [String,File,Object] manifest_csv the manifest argument
      # @param [String] dir the directory containing the source records;
      #   optional if +dir+ can be derived from +manifest_csv+
      def get_source_dir manifest_csv, dir
        case
        when dir.present? && File.directory?(dir)
          dir
        when manifest_csv.is_a?(File)
          File.dirname manifest_csv.path
        when manifest_csv.is_a?(String) && File.exist?(manifest_csv)
          return File.dirname(manifest_csv)
        else
          raise DSError, "Cannot get source directory from CSV #{manifest_csv.class}"
        end
      end

      ##
      # Return a CSV::Table for +manifest_csv+. Determine +manifest_csv+
      # type and return the value (if a CSV::Table) or return the parsed
      # value as appropriate.
      #
      # @param [CSV::Table,IO,StringIO,String] manifest_csv either a parse CSV,
      #   an IO instance, a StringIO, a String CSV or the manifest path
      # @return [CSV::Table] the parse manifest
      def get_csv_data manifest_csv
        case manifest_csv
        when IO, StringIO
          CSV.parse manifest_csv, headers: true
        when CSV::Table
          manifest_csv
        when String
          if File.exist? manifest_csv
            CSV.parse File.open(manifest_csv, 'r').read, headers: true
          else
            CSV.parse manifest_csv, headers: true
          end
        else
          raise ArgumentError, "Cannot process input as CSV: #{manifest_csv.inspect}"
        end
      end
    end
  end
end