# frozen_string_literal: true

require 'csv'

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
  #   - Confirms all listed input files match the record identifier provided in the manifest
  #
  class ManifestValidator

    INSTITUTION_WIKIDATA_QID            = 'holding_institution_wikidata_qid'
    FILENAME                            = 'filename'
    INSTITUTION_WIKIDATA_LABEL          = 'holding_institution_wikidata_label'
    SOURCE_DATA_TYPE                    = 'source_data_type'
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
      SOURCE_DATA_TYPE,
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
      SOURCE_DATA_TYPE,
      INSTITUTIONAL_ID,
      INSTITUTIONAL_ID_LOCATION_IN_SOURCE,
      RECORD_LAST_UPDATED,
      CALL_NUMBER,
      MANIFEST_GENERATED_AT
    ]

    ##
    # @param [String] manifest_csv path to manifest CSV
    # @return [boolean] true if the manifest is valid
    def validate manifest_csv
      data = CSV.readlines manifest_csv, headers: true
      return false unless validate_columns data
      true
    end

    ##
    # @param [CSV::Table] data parsed CSV
    # @return [boolean] true if all require columns present
    def validate_columns data
      found_columns = data.first.to_h.keys
      diff = MANIFEST_COLUMNS - found_columns
      return true if diff.empty?
      STDERR.puts "Manifest missing required columns: #{diff.join ', '}"
    end

    ##
    # @param [CSV::Table] data parsed CSV
    # @return [boolean] true if all require values present
    def validate_required_values data
      is_valid = true
      data.each do |row|
        REQUIRED_VALUES.each_with_index do |col, ndx|
          # require 'pry'; binding.pry if col == INSTITUTION_WIKIDATA_QID
          if row[col].blank?
            STDERR.puts "Required value missing row: #{ndx}; col.: #{col}"
            is_valid = false
          end
        end
      end
      is_valid
    end

    ##
    # @param [CSV::Table] data parsed CSV
    # @return [boolean] true if all data types are valid
    def validate_data_types data

    end

    ##
    # @param [CSV::Table] data parsed CSV
    # @return [boolean] true if all list input files are present
    def validate_files data

    end

    ##
    # @param [CSV::Table] data parsed CSV
    # @return [boolean] true if all +holding_institution_institutional_id+
    #     values match source file
    def validate_ids data

    end
  end
end