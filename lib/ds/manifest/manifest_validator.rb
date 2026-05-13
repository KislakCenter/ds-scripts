# frozen_string_literal: true

require 'csv'
require 'uri'
require 'date'
require_relative './constants'

module DS
  module Manifest
    ##
    # Validate a DS input manifest.
    #
    # Validation does the following:
    #
    #   - Confirms all required columns are present
    #   - Confirms all all required values are present
    #   - Confirms all column values are the correct type
    #   - Confirms all listed input files are present
    #   - Confirms all listed input files match the record
    #     lookup value provided in the manifest
    #
    # @todo Add test for live URLs
    class ManifestValidator
      include DS::Manifest::Constants

      attr_reader :manifest
      attr_reader :source_dir
      attr_reader :errors

      URI_REGEXP = URI::DEFAULT_PARSER.make_regexp %w{http https}
      QID_REGEXP = %r{\AQ\d+\z}

      ##
      # @param [DS::Manifest] manifest DS::Manifest instance
      # @return [DS::ManifestValidator]
      def initialize manifest
        @manifest = manifest
        @errors   = []
        @lookup_validators = {}
      end

      ##
      # @return [boolean] true if the manifest is valid
      def valid?
        return false unless validate_columns
        return false unless validate_required_values
        return false unless validate_lookups_unique
        return false unless validate_data_types
        return false unless validate_files_exist
        return false unless validate_records_present
        true
      end

      ##
      # @return [boolean] true if all required columns are present
      def validate_columns
        found_columns = manifest.headers
        diff          = MANIFEST_COLUMNS - found_columns
        return true if diff.blank?
        add_error "Manifest missing required columns: #{diff.join ', '}" if diff.present?
        false
      end

      ##
      # @return [boolean] true if all require values present
      def validate_required_values
        is_valid = true
        manifest.each_with_index do |row, ndx|
          REQUIRED_VALUES.each do |col|
            if row[col].blank?
              add_error "Required value missing in row: #{ndx+1}, col.: #{col}"
              is_valid = false
            end
          end
        end
        is_valid
      end

      ##
      # @return [boolean] true if all data types are valid
      def validate_data_types
        is_valid = true
        manifest.each_with_index do |entry, row_num|
          is_valid = false unless validate_urls entry, row_num
          is_valid = false unless validate_qids entry, row_num
          is_valid = false unless validate_dates entry, row_num
        end
        is_valid
      end

      ##
      # @return [boolean] true if all list input files are present
      def validate_files_exist
        is_valid = true
        manifest.each_with_index do |entry, row_num|
          file_path = File.join manifest.source_dir, entry.filename
          unless File.exist? file_path
            is_valid = false
            add_error "Source file not found row: #{row_num+1}; source directory: #{source_dir}; file: #{entry.filename}"
          end
        end
        is_valid
      end

      # Validates the uniqueness of all Lookup values in the manifest.
      #
      # This method collects the count of all Lookup values in the manifest and selects those with a count greater than 1.
      # It then iterates over the multiples and adds an error for each duplicate ID found.
      #
      # Returns:
      # - `true` if no duplicate IDs are found.
      # - `false` if duplicate IDs are found.
      def validate_lookups_unique
        fields_to_check = [:institution_ds_qid, :institutional_id, :call_number, :link_to_institutional_record]

        # collect the count of all ids and select those with a count > 1
        multiples = manifest.inject({}) { |h, entry|
          key = fields_to_check.map { |f| entry.send(f) }.join('|')
          h[key] ||= 0; h[key] += 1; h
        }.filter_map { |key, count|
          [key, count] if count > 1
        }

        return true if multiples.blank?

        multiples.each do |key, count|
          add_error "Duplicate Lookup found in manifest: Lookup value '#{key}' found in #{count} rows"
        end
        false
      end

      ##
      # @return [boolean] true if all +record_lookup_value+
      #     values match source file
      def validate_records_present
        is_valid = true
        manifest.each_with_index do |entry, row_num|
          file_path = File.join manifest.source_dir, entry.filename

          lookup_value      = entry.record_lookup_value
          lookup_validator = get_lookup_validator entry.source_type
          found        = lookup_validator.valid? file_path, lookup_value, entry.lookup_value_location_in_source

          unless found
            is_valid = false
            lookup_validator.errors.each { |error| add_error error }
          end
        end
        is_valid
      end

      # Handles the error when the count of records found for a given `inst_id` and `location_in_source` is
      # 0 or more than 1.
      #
      # @param count [Integer] the number of records found for the given `inst_id` and `location_in_source`
      # @param inst_id [String] the identifier of the record
      # @param location_in_source [String] the location in the source where the record is found
      # @return [nil]
      def handle_count_error count, lookup_value, location_in_source
        return if count == 1

        if count > 1
          add_error "ERROR: Multiple records (#{count}) found for lookup value: #{lookup_value} (location: #{location_in_source})"
        elsif count == 0
          add_error "ERROR: No records found for lookup value: #{lookup_value} (location: #{location_in_source})"
        end
        nil
      end

      ####################################
      # Type validations
      ####################################
      def validate_source_type entry, row_num
        is_valid = true

        unless source_types.include? entry.source_type
          add_error "Invalid source type in row: #{row_num+1}; expected one of #{VALID_SOURCE_TYPES.join ', '}; got: '#{entry.source_type}'"
          is_valid = false
        end
        is_valid
      end

      def validate_urls entry, row_num
        is_valid = true
        URI_COLUMNS.each do |col|
          if entry[col].present? && entry[col].to_s !~ URI_REGEXP
            add_error "Invalid URL in row: #{row_num+1}; col.: #{col}: '#{entry[col]}'"
            is_valid = false
          end
        end
        is_valid
      end

      def validate_qids entry, row_num
        is_valid = true
        QID_COLUMNS.each do |col|
          unless entry[col].to_s =~ QID_REGEXP
            is_valid = false
            add_error "Invalid QID in row: #{row_num+1}; col.: #{col}: '#{entry[col]}'"
          end
        end
        is_valid
      end

      def validate_dates entry, row_num
        is_valid = true
        DATE_TIME_COLUMNS.each do |col|
          next if entry[col].blank?
          begin
            Date.parse entry[col]
          rescue Date::Error
            is_valid = false
            add_error "Invalid date in row: #{row_num+1}, col.: #{col}: '#{entry[col]}'"
          end
        end
        is_valid
      end

      # Adds an error message to the list of errors.
      #
      # @param message [String] the error message to add
      # @return [void]
      def add_error message
        @errors << message
      end

      # Checks if there are any errors in the errors collection.
      #
      # @return [Boolean] true if there are errors, false otherwise
      def has_errors?
        errors.any?
      end

      # Retrieves the appropriate ID validator for the given source type.
      #
      # @param source_type [Symbol] the type of the source
      # @return [DS::Manifest::BaseIdValidator] the ID validator for the source type
      # @raise [NotImplementedError] if the source type is not implemented
      def get_lookup_validator source_type
        case source_type
        when DS::Constants::MARC_XML
          @lookup_validators[source_type] ||= SimpleXmlLookupValidator.new(DS::Source::MarcXML.new)
        when DS::Constants::DS_METS
          @lookup_validators[source_type] ||= SimpleXmlLookupValidator.new(DS::Source::DSMetsXML.new)
        when DS::Constants::TEI_XML
          @lookup_validators[source_type] ||= SimpleXmlLookupValidator.new(DS::Source::TeiXML.new)
        when DS::Constants::DS_CSV
          @lookup_validators[source_type] ||= DsCsvLookupValidator.new(DS::Source::DSCSV.new)
        else
          raise NotImplementedError, "validate_lookups not implemented for: #{source_type}"
        end
      end

      def source_types
        VALID_SOURCE_TYPES
      end
    end
  end
end
