# frozen_string_literal: true

module DS
  module Mapper
    class BaseMapper
      attr_reader :timestamp
      attr_reader :source_dir
      attr_reader :source

      # Initializes a new instance of the class.
      #
      # @param source_dir [String] the directory where the source files are located
      # @param timestamp [Time] the timestamp of the source files
      # @param source [DS::Source::BaseSource] the source object
      # @return [void]
      def initialize source_dir:, timestamp:, source:
        @source = source
        @source_dir = source_dir
        @timestamp = timestamp
      end

      # Extracts a record from the given entry.
      #
      # @param [DS::Manifest::Entry] entry the entry representing one row in a manifest
      # @return [Object] the extracted record; e.g., a Nokogiri::XML::Node or CSV::Row
      # @raise [NotImplementedError] if the method is not implemented in a subclass
      def extract_record entry
        raise NotImplementedError
      end

      # Maps a record from the given entry.
      #
      # @param [DS::Manifest::Entry] entry the entry representing one row in a manifest
      # @return [Hash<Symbol, String>] the mapped record
      # @raise [NotImplementedError] if the method is not implemented in a subclass
      def map_record entry
        raise NotImplementedError
      end
    end
  end
end
