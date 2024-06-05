# frozen_string_literal: true

module DS
  module Manifest
    ##
    # A {DS::Manifest::BaseIdValidator} is a base class for a
    # cacheable ID validator for sources. The validator is responsible
    # for opening and caching source files and dtermining that one
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
    #   - +#open_source+, required by DS::Source::SourceCache
    #
    class BaseIdValidator
      include DS::Source::SourceCache

      attr_reader :errors

      def initialize
        @errors = []
      end

      # Checks if the given file path, id, and id location are valid.
      #
      # @param file_path [String] The path to the file.
      # @param id [String] The id to check.
      # @param id_location [String] The location of the id.
      # @return [Boolean] Returns true if the records size is equal to 1, false otherwise.
      def valid? file_path, id, id_location
        records = locate_record file_path, id, id_location

        return true if records.size == 1
        handle_count_error records.size, id, id_location
        false
      end

      # Locates a record based on the given source path, ID, and ID location.
      #
      # @param source_path [String] the path to the source file
      # @param id [String] the ID of the record
      # @param id_location [String] the location of the ID within the record
      # @raise [NotImplementedError] this method is not implemented and should be overridden
      # @return [Array<Object>] an array of objects for each record
      def locate_record source_path, id, id_location
        raise NotImplementedError
      end

      def handle_count_error count, inst_id, location_in_source
        return if count == 1

        if count > 1
          add_error "ERROR: Multiple records (#{count}) found for id: #{inst_id} (location: #{location_in_source})"
        elsif count == 0
          add_error "ERROR: No records found for id: #{inst_id} (location: #{location_in_source})"
        end
        nil
      end

      def add_error message
        @errors << message
      end
    end
  end
end
