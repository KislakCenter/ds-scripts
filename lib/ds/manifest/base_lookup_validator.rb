# frozen_string_literal: true

module DS
  module Manifest
    ##
    # A {DS::Manifest::BaseIdValidator} is a base class for a
    # cacheable ID validator for sources. The validator is responsible
    # for opening and caching source files and determining that one
    # record is found for each source +id+ at the specified
    # +id_location+ in the parsed source.
    #
    # The motivation for this class is to handle ID validation for
    # source types that can have multiple records per source file,
    # saving the time required to parse the source file for each check.
    #
    # Concrete subclasses of {DS::Manifest::BaseIdValidator} must implement
    #
    #   - +#locate_record+, required this class
    #
    class BaseLookupValidator

      attr_reader :errors
      attr_reader :source

      ##
      # Create a new Lookup Validator
      #
      # @param source [DS::Source::BaseSource] the source to validate
      # @return [void]
      def initialize source
        @source = source
        @errors = []
      end

      # Checks if the given file path, lookup_value, and lookup_value_location are valid.
      #
      # @param file_path [String] The path to the file.
      # @param lookup_value [String] The lookup_value to check.
      # @param lookup_value_location [String] The location of the lookup_value in the source.
      # @return [Boolean] Returns true if the records size is equal to 1, false otherwise.
      def valid? file_path, lookup_value, lookup_value_location
        records = locate_record file_path, lookup_value, lookup_value_location
        return true if records.size == 1

        handle_count_error records.size, lookup_value, lookup_value_location
        false
      end

      # Locates a record based on the given source path, lookup_value and lookup_value_location.
      #
      # @param source_path [String] the path to the source file
      # @param lookup_value [String] the lookup value for the record; e.g, MMSID
      # @param lookup_value_location [String] the location of the
      #   lookup_value_location within the record; e.g., column name or XPath
      # @raise [NotImplementedError] this method is not implemented and should be overridden
      # @return [Array<Object>] an array of objects for each record
      def locate_record source_path, lookup_value, lookup_value_location
        raise NotImplementedError
      end

      def handle_count_error count, lookup_value, lookup_value_location
        return if count == 1

        if count > 1
          add_error "ERROR: Multiple records (#{count}) found for id: #{lookup_value} (location: #{lookup_value_location})"
        elsif count.zero?
          add_error "ERROR: No records found for id: #{lookup_value} (location: #{lookup_value_location})"
        end
        nil
      end

      def add_error message
        @errors << message
      end
    end
  end
end
