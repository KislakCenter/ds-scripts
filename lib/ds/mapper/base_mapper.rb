# frozen_string_literal: true

module DS
  module Mapper
    class BaseMapper
      attr_reader :timestamp
      attr_reader :source_dir
      attr_reader :source_cache

      def initialize source_dir:, timestamp:
        @source_dir = source_dir
        @timestamp  = timestamp
        @source_cache = DS::Util::Cache.new
      end

      def extract_record entry
        raise NotImplementedError
      end

      def map_record entry
        raise NotImplementedError
      end

      def find_or_open_source entry
        key = source_file_key entry
        return source_cache.get_item key if source_cache.include? key
        source = open_source entry
        source_cache.add key, source
        source
      end

      def open_source entry
        raise NotImplementedError
      end

      def source_file_key entry
        { source_dir: source_dir, filename: entry.filename }
      end

      def ==(other)
        super || self.class == other.class &&
          timestamp == other.timestamp &&
          source_dir == other.source_dir
      end
    end
  end
end