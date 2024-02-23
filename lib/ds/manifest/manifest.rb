# frozen_string_literal: true

require 'csv'

module DS
  module Manifest
    class Manifest
      include Enumerable

      attr_reader :csv_path
      attr_reader :source_dir

      ##
      # Create a new Manifest instance. If +dir+ is not provided,
      # directory containing source files must the same as the
      # +manifest_csv+ directory.
      #
      # @param [String] csv_path manifest CSV path
      # @param [String] dir optional path to the directory containing the
      #   source file(s); if
      # @return [DS::Manifest::Manifest] a new Manifest instance
      def initialize csv_path, dir = nil
        @csv_path = csv_path
        @source_dir = get_source_dir dir
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
          yield DS::Manifest::Entry.new row, self
        end
      end

      ##
      # Return the String path of the directory expected to contain
      # the source records. If +dir+ is present, return
      # +dir+; otherwise, return the directory of the manifest
      # CSV.
      #
      # @param [String] dir a source directory path or +nil+
      # @return [String] the directory containing source files
      def get_source_dir dir
        return dir if dir.present?
        File.dirname csv.path
      end

      ##
      # Return a CSV::Table for +manifest_csv+. Determine +manifest_csv+
      # type and return the value (if a CSV::Table) or return the parsed
      # value as appropriate.
      #
      # @return [CSV::Table] the parsed manifest
      def csv
        @csv ||= CSV.open csv_path, 'r', headers: true
        @csv.rewind
        @csv
      end
    end
  end
end