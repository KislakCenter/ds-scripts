# frozen_string_literal: true

require 'csv'
require 'uri'
require 'date'

module DS
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

    attr_reader :manifest
    attr_reader :source_dir

    def self.normalize_lookup value
      return '' if value.blank?
      value.to_s.downcase.strip.gsub %r{\W+}, ''
    end

    INSTITUTION_WIKIDATA_QID            = 'holding_institution_wikidata_qid'
    FILENAME                            = 'filename'
    INSTITUTION_WIKIDATA_LABEL          = 'holding_institution_wikidata_label'
    SOURCE_TYPE                         = 'source_data_type'
    DS_ID                               = 'ds_id'
    INSTITUTIONAL_ID                    = 'holding_institution_institutional_id'
    INSTITUTIONAL_ID_LOCATION_IN_SOURCE = 'institutional_id_location_in_source'
    RECORD_LAST_UPDATED                 = 'record_last_updated'
    CALL_NUMBER                         = 'call_number'
    TITLE                               = 'title'
    IIIF_MANIFEST_URL                   = 'iiif_manifest_url'
    LINK_TO_INSTITUTIONAL_RECORD        = 'link_to_institutional_record'
    MANIFEST_GENERATED_AT               = 'manifest_generated_at'

    MANIFEST_COLUMNS = [
      INSTITUTION_WIKIDATA_QID,
      INSTITUTION_WIKIDATA_LABEL,
      FILENAME,
      SOURCE_TYPE,
      DS_ID,
      INSTITUTIONAL_ID,
      INSTITUTIONAL_ID_LOCATION_IN_SOURCE,
      RECORD_LAST_UPDATED,
      CALL_NUMBER,
      TITLE,
      IIIF_MANIFEST_URL,
      LINK_TO_INSTITUTIONAL_RECORD,
      MANIFEST_GENERATED_AT
    ].freeze

    REQUIRED_VALUES = [
      INSTITUTION_WIKIDATA_QID,
      FILENAME,
      INSTITUTION_WIKIDATA_LABEL,
      SOURCE_TYPE,
      INSTITUTIONAL_ID,
      INSTITUTIONAL_ID_LOCATION_IN_SOURCE,
      RECORD_LAST_UPDATED,
      CALL_NUMBER,
      MANIFEST_GENERATED_AT
    ].freeze

    URI_COLUMNS = [
      LINK_TO_INSTITUTIONAL_RECORD,
      IIIF_MANIFEST_URL
    ].freeze

    QID_COLUMNS = [
      INSTITUTION_WIKIDATA_QID
    ].freeze

    DATE_TIME_COLUMNS = [
      RECORD_LAST_UPDATED,
      MANIFEST_GENERATED_AT
    ].freeze

    MARC_XML = 'MARC XML'
    TEI_XML  = 'TEI XML'
    DS_CSV   = 'DS CSV'
    DS_METS  = 'DS METS XML'

    # source type list of all type names and normalized names; i.e.,
    # lower case names stripped of all whitespace and non-word characters
    VALID_SOURCE_TYPES = [
      MARC_XML,
      TEI_XML,
      DS_CSV,
      DS_METS
    ].freeze

    SOURCE_TYPE_LOOKUP = VALID_SOURCE_TYPES.flat_map { |type|
      normal = ManifestValidator.normalize_lookup type
      [type, normal]
    }.freeze

    XML_SOURCE_TYPES = SOURCE_TYPE_LOOKUP.select { |t| t =~ %r{xml}i }
    CSV_SOURCE_TYPES = SOURCE_TYPE_LOOKUP.select { |t| t =~ %r{csv}i }

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
      found_columns = manifest.csv.first.headers
      diff = MANIFEST_COLUMNS - found_columns
      return true if diff.empty?
      STDERR.puts "Manifest missing required columns: #{diff.join ', '}"
    end

    ##
    # @return [boolean] true if all require values present
    def validate_required_values
      is_valid = true
      manifest.csv.each do |row|
        REQUIRED_VALUES.each_with_index do |col, ndx|
          if row[col].blank?
            STDERR.puts "Required value missing row: #{ndx}; col.: #{col}"
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
      manifest.csv.each_with_index do |row, row_num|
        is_valid = false unless validate_urls row, row_num
        is_valid = false unless validate_qids row, row_num
        is_valid = false unless validate_dates row, row_num
      end
      is_valid
    end

    ##
    # @return [boolean] true if all list input files are present
    def validate_files_exist
      is_valid = true
      manifest.csv.each_with_index do |row, row_num|
        file_path = File.join manifest.source_dir, row[FILENAME]
        unless File.exist? file_path
          is_valid = false
          STDERR.puts "Source file not found row: #{row_num}; source directory: #{source_dir}; file: #{row[FILENAME]}"
        end
      end
      is_valid
    end

    ##
    # @return [boolean] true if all +holding_institution_institutional_id+
    #     values match source file
    def validate_ids
      is_valid = true
      manifest.csv.each_with_index do |row, row_num|
        file_path      = File.join manifest.source_dir, row[FILENAME]
        source_type    = row[SOURCE_TYPE]

        normal_source  = ManifestValidator.normalize_lookup source_type
        inst_id        = row[INSTITUTIONAL_ID]
        found = case normal_source
                when 'MARC XML', 'marcxml'
                  id_in_marc_xml? file_path, inst_id
                else
                  raise NotImplementedError("validate_ids not implemented for: #{source_type}")
                end
        unless found
          STDERR.puts "ID not found in source file row: #{row}; id: #{inst_id}; source_file: #{row[FILENAME]}"
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
      record = File.open(file_path) { |f| Nokogiri::XML(f) }
      record.remove_namespaces!

      xpath = "//controlfield[@tag='001' and text() = #{id}]"
      record.xpath(xpath).to_a.present?
    end

    ####################################
    # Type validations
    ####################################
    def validate_source_type row, row_num
      is_valid = true
      col = SOURCE_TYPE

      unless SOURCE_TYPE_LOOKUP.include? ManifestValidator.normalize_lookup row[col]
        STDERR.puts "Invalid source type in row: #{row_num}; expected one of #{VALID_SOURCE_TYPES.join ', '}; got: '#{row[col]}'"
        is_valid = false
      end
      is_valid
    end

    def validate_urls row, row_num
      is_valid = true
      URI_COLUMNS.each do |col|
        unless row[col].to_s =~ URI_REGEXP
          STDERR.puts "Invalid URL in row: #{row_num}; col.: #{col}: '#{row[col]}'"
          is_valid = false
        end
      end
      is_valid
    end

    def validate_qids row, row_num
      is_valid = true
      QID_COLUMNS.each do |col|
        unless row[col].to_s =~ QID_REGEXP
          is_valid = false
          STDERR.puts "Invalid QID in row: #{row_num}; col.: #{col}: '#{row[col]}'"
        end
      end
      is_valid
    end

    def validate_dates row, row_num
      is_valid = true
      DATE_TIME_COLUMNS.each do |col|
        next if row[col].blank?
        begin
          Date.parse row[col]
        rescue Date::Error
          is_valid = false
          STDERR.puts "Invalid date in row: #{row_num}, col.: #{col}: '#{row[col]}'"
        end
      end
      is_valid
    end
  end
end