# frozen_string_literal: true

module DS
  module Util

    ##
    # This module provides methods for caching and opening source files.
    # It is used by the DS::Mapper::BaseMapper class.
    #
    # It makes available a +#find_or_open_source+ method that can be used
    # by the including class to open or retrieve a parse source file
    # from the cache.
    #
    # Including classes must implement the +open_source+ method.
    #
    # The file +path+ is used as the cache key.
    #
    # The initial cache size is the value of DS::Util::Cache::DEFAULT_MAX_SIZE.
    #
    # Cache max size can be set and retrieved using the +max_cache_size+ and +max_cache_size=+ methods. #
    module SourceCache

      # Finds or opens a source file at the given path.
      #
      # @param source_path [String] the path to the source file
      # @return [Object] the contents of the source file
      def find_or_open_source source_path
        return cache.get_item source_path if cache.include? source_path
        source = open_source source_path
        cache.add source_path, source
        source
      end

      # Opens a source file at the given path.
      #
      # @param source_path [String] the path to the source file
      # @return [Object] the contents of the source file
      # @raise [NotImplementedError] unless implemented by including class
      def open_source source_path
        raise NotImplementedError
      end

      # Returns the cache object.
      #
      # This method lazily initializes the cache object if it is not already initialized.
      # The cache object is an instance of the DS::Util::Cache class.
      #
      # @return [DS::Util::Cache] the cache object
      def cache
        @cache ||= DS::Util::Cache.new
      end

      # Sets the maximum cache size.
      #
      # @param size [Integer] the maximum number of items to store in the cache
      # @return [void]
      def max_cache_size= size
        cache.max_size = size
      end

      # Returns the maximum cache size.
      #
      # @return [Integer] the maximum number of items to store in the cache
      def max_cache_size
        cache.max_size
      end
    end
  end
end
