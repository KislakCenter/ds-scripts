# frozen_string_literal: true
module DS
  module Manifest
    module Constants
      include DS

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

    end
  end
end
