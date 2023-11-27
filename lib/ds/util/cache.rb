# frozen_string_literal: true

module DS
  module Util
    class Cache
      DEFAULT_MAX_SIZE = 10
      UNLIMITED_SIZE = Float::INFINITY

      attr_reader :max_size
      attr_reader :items
      attr_reader :keys

      def initialize max_size: DEFAULT_MAX_SIZE
        @max_size = max_size
        @items    = {}
      end

      def get_or_add key, item
        add(key, item) unless include? key && unlimited?
        get_item key
      end

      def add key, item
        delete_item key
        items[key] = item
        cleanup
        item
      end

      def include? key
        keys.include? key
      end

      def unlimited?
        max_size == UNLIMITED_SIZE
      end

      def get_item key
        items[key]
      end

      def [](key)
        get_item key
      end

      def keys
        items.keys
      end

      def size
        keys.size
      end

      def delete_item key
        items.delete key
      end

      def cleanup
        return if size < max_size
        return if keys.blank? # don't allow an infinite loop
        while size > max_size
          delete_item keys.first
        end
      end
    end
  end
end