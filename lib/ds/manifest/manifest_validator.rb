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

      URI_REGEXP = URI::DEFAULT_PARSER.make_regexp %w{http https}
      QID_REGEXP = %r{\AQ\d+\z}

      ##
      # @param [DS::Manifest] manifest DS::Manifest instance
      # @return [DS::ManifestValidator]
      def initialize manifest
        @manifest = manifest
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
        return true if diff.empty?
        STDERR.puts "Manifest missing required columns: #{diff.join ', '}"
      end

      ##
      # @return [boolean] true if all require values present
      def validate_required_values
        is_valid = true
        manifest.each_with_index do |row, ndx|
          REQUIRED_VALUES.each do |col|
            if row[col].blank?
              STDERR.puts "Required value missing in row: #{ndx+1}, col.: #{col}"
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
            STDERR.puts "Source file not found row: #{row_num+1}; source directory: #{source_dir}; file: #{entry.filename}"
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
                            id_in_marc_xml? file_path, inst_id
                          else
                            raise NotImplementedError("validate_ids not implemented for: #{source_type}")
                          end
          unless found
            STDERR.puts "ID not found in source file row: #{row_num+1}; id: #{inst_id}; source_file: #{entry.filename}"
            is_valid = false
          end
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

      def id_in_marc_xml? file_path, id
        entry = File.open(file_path) { |f| Nokogiri::XML(f) }
        entry.remove_namespaces!

        xpath = "//controlfield[@tag='001' and text() = #{id}]"
        entry.xpath(xpath).to_a.present?
      end

      ####################################
      # Type validations
      ####################################
      def validate_source_type entry, row_num
        is_valid = true

        unless source_types.include? entry.source_type
          STDERR.puts "Invalid source type in row: #{row_num+1}; expected one of #{VALID_SOURCE_TYPES.join ', '}; got: '#{entry.source_type}'"
          is_valid = false
        end
        is_valid
      end

      def validate_urls entry, row_num
        is_valid = true
        URI_COLUMNS.each do |col|
          if entry[col].present? && entry[col].to_s !~ URI_REGEXP
            STDERR.puts "Invalid URL in row: #{row_num+1}; col.: #{col}: '#{entry[col]}'"
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
            STDERR.puts "Invalid QID in row: #{row_num+1}; col.: #{col}: '#{entry[col]}'"
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
            STDERR.puts "Invalid date in row: #{row_num+1}, col.: #{col}: '#{entry[col]}'"
          end
        end
        is_valid
      end

      def source_types
        VALID_SOURCE_TYPES
      end
    end
  end
end