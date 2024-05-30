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
    #     identifier provided in the manifest
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
      end

      ##
      # @return [boolean] true if the manifest is valid
      def valid?
        return false unless validate_columns
        return false unless validate_required_values
        return false unless validate_data_types
        return false unless validate_files_exist
        return false unless validate_ids
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

      ##
      # @return [boolean] true if all +holding_institution_institutional_id+
      #     values match source file
      def validate_ids
        is_valid = true
        manifest.each_with_index do |entry, row_num|
          file_path   = File.join manifest.source_dir, entry.filename

          source_type = entry.source_type

          normal_source = DS.normalize_key source_type
          inst_id       = entry.institutional_id
          found         = case normal_source
                          when 'MARC XML', 'marcxml'
                            id_in_marc_xml? file_path, inst_id, entry.institutional_id_location_in_source
                          when 'teixml'
                            id_in_xml? file_path, inst_id, entry.institutional_id_location_in_source
                          when 'dsmetsxml'
                            id_in_xml? file_path, inst_id, entry.institutional_id_location_in_source
                          when 'dscsv'
                            id_in_csv? file_path, inst_id, entry.institutional_id_location_in_source
                          else
                            raise NotImplementedError, "validate_ids not implemented for: #{source_type}"
                          end
            is_valid = false unless found
        end
        is_valid
      end

      NAMESPACES = {
        marc:  'http://www.loc.gov/MARC21/slim',
        mets:  'http://www.loc.gov/METS/',
        mods:  'http://www.loc.gov/mods/v3',
        rts:   'http://cosimo.stanford.edu/sdr/metsrights/',
        mix:   'http://www.loc.gov/mix/v10',
        xlink: 'http://www.w3.org/1999/xlink',
        xsi:   'http://www.w3.org/2001/XMLSchema-instance',
        xs:    'http://www.w3.org/2001/XMLSchema',
        xd:    'http://www.oxygenxml.com/ns/doc/xsl',
        tei:   'http://www.tei-c.org/ns/1.0'
      }


      def id_in_marc_xml? file_path, inst_id, source_location
        xml = File.open(file_path) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!

        xpath = "//record[#{source_location} = '#{inst_id}']"
        records = xml.xpath(xpath)

        return true if records.size == 1

        handle_count_error records.size, inst_id, xpath
        false
      end

      def id_in_xml? file_path, id, xpath
        xml = File.open(file_path) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        id_in_source = xml.xpath(xpath)

        return true if id_in_source.size == 1

        handle_count_error id_in_source.size, id, xpath
        false
      end

      def id_in_csv? file_path, id, location
        csv = CSV.readlines file_path, headers: true
        records = csv.filter_map { |row| row if row[location] == id}

        handle_count_error records.size, id, location
        return true if records.size == 1
      end

      # Handles the error when the count of records found for a given `inst_id` and `location_in_source` is
      # 0 or more than 1.
      #
      # @param count [Integer] the number of records found for the given `inst_id` and `location_in_source`
      # @param inst_id [String] the identifier of the record
      # @param location_in_source [String] the location in the source where the record is found
      # @return [nil]
      def handle_count_error count, inst_id, location_in_source
        return if count == 1

        if count > 1
          add_error "ERROR: Multiple records (#{count}) found for id: #{inst_id} (location: #{location_in_source})"
        elsif count == 0
          add_error "ERROR: No records found for id: #{inst_id} (location: #{location_in_source})"
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


      def source_types
        VALID_SOURCE_TYPES
      end
    end
  end
end
