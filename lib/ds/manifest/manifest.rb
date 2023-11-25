# frozen_string_literal: true

require 'csv'

module DS
  module Manifest
    class Manifest
      include Enumerable

      attr_reader :path
      attr_reader :source_dir

      ##
      # Create a new Manifest instance. If +dir+ is not provided,
      # directory containing source files must the same as the
      # +manifest_csv+ directory.
      #
      # @param [String] path the manifest path
      # @param [String] dir optional path to the directory containing the
      #   source file(s); if
      # @return [DS::Manifest::Manifest] a new Manifest instance
      def initialize path, dir = nil
        @path       = path
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
      # Return the String path of the directory expected to contain the
      # source records. If +dir+ is present, return +dir+; otherwise,
      # return the path to the manifest CSV.
      #
      # @param [String] dir a source dir path or +nil+
      # @return [String] the directory containing source files
      def get_source_dir dir
        return dir if dir.present?
        csv.path
      end

      ##
      # Return a CSV::Table for +manifest_csv+. Determine +manifest_csv+
      # type and return the value (if a CSV::Table) or return the parsed
      # value as appropriate.
      #
      # @return [CSV::Table] the parse manifest
      def csv
        @csv ||= CSV.open path, 'r', headers: true
      end
    end
  end
end