# frozen_string_literal: true

module DS
  module Mapper
    class BaseMapper
      include DS::Util::SourceCache

      attr_reader :timestamp
      attr_reader :source_dir

      def initialize source_dir:, timestamp:
        @source_dir = source_dir
        @timestamp  = timestamp
      end

      def extract_record entry
        raise NotImplementedError
      end

      def map_record entry
        raise NotImplementedError
      end

      def ==(other)
        super || self.class == other.class &&
          timestamp == other.timestamp &&
          source_dir == other.source_dir
      end
    end
  end
end
