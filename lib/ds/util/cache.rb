# frozen_string_literal: true

module DS
  module Util
    class Cache
      DEFAULT_MAX_SIZE = 10
      UNLIMITED_SIZE = Float::INFINITY

      attr_accessor :max_size
      attr_reader :items
      attr_reader :keys

      # Initializes a new instance of the class with the specified maximum size.
      #
      # @param max_size [Integer] (DEFAULT_MAX_SIZE) the maximum size of the cache
      # @return [void]
      def initialize max_size: DEFAULT_MAX_SIZE
        @max_size = max_size
        @items    = {}
      end

      # Adds an item to the cache if it is not already present, or if the cache is not limited and the item is not already present.
      #
      # @param key [Object] the key used to identify the item in the cache
      # @param item [Object] the item to be added to the cache
      # @return [Object] the item that was added to the cache
      def get_or_add key, item
        add(key, item) unless include? key && unlimited?
        get_item key
      end

      # Adds an item to the cache if it is not already present, or if the cache is not limited and the item is not already present.
      #
      # @param key [Object] the key used to identify the item in the cache
      # @param item [Object] the item to be added to the cache
      # @return [Object] the item that was added to the cache
      def add key, item
        delete_item key
        items[key] = item
        cleanup
        item
      end

      # Checks if the given key is present in the cache.
      #
      # @param key [Object] the key to check for in the cache
      # @return [Boolean] true if the key is present in the cache, false otherwise
       def include? key
        keys.include? key
      end

      # Checks if the cache is unlimited.
      #
      # @return [Boolean] true if the cache is unlimited, false otherwise
      def unlimited?
        max_size == UNLIMITED_SIZE
      end

      # Retrieves an item from the cache using the specified key.
      #
      # @param key [Object] The key used to identify the item in the cache.
      # @return [Object] The item associated with the specified key, or nil if the key is not present in the cache.
      def get_item key
        items[key]
      end

      # Retrieves an item from the cache using the specified key.
      #
      # @param key [Object] The key used to identify the item in the cache.
      # @return [Object] The item associated with the specified key, or nil if the key is not present in the cache.
      def [](key)
        get_item key
      end

      # Returns an array of all the keys in the cache.
      #
      # @return [Array<Object>] An array of keys.
      def keys
        items.keys
      end

      # Returns the number of items in the cache.
      #
      # @return [Integer] The number of items in the cache.
      def size
        keys.size
      end

      # Deletes an item from the cache using the specified key.
      #
      # @param key [Object] The key used to identify the item in the cache.
      # @return [void]
      def delete_item key
        items.delete key
      end

      # Cleanup the cache by removing items until the size is less than or equal to the maximum size.
      #
      # This method does not take any parameters.
      #
      # @return [void]
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
