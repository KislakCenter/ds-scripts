# frozen_string_literal: true

require_relative './constants'
module DS
  module Manifest
    class Record
      include DS::Manifest::Constants

      attr_reader :row
      ##
      # @param [CSV::Row] row a manifest CSV row
      def initialize row
        @row = row
      end

      def [] key
        row[key]
      end

      def institution_wikidata_qid
        row[INSTITUTION_WIKIDATA_QID]
      end

      # FILENAME                            = 'filename'
      def filename
        row[FILENAME]
      end

      def institution_wikidata_label
        row[INSTITUTION_WIKIDATA_LABEL]
      end

      def source_type
        row[SOURCE_TYPE]
      end
      # DS_ID                               = 'ds_id'
      def ds_id
        row[DS_ID]
      end
      # INSTITUTIONAL_ID                    = 'holding_institution_institutional_id'
      def institutional_id
        row[INSTITUTIONAL_ID]
      end

      # INSTITUTIONAL_ID_LOCATION_IN_SOURCE = 'institutional_id_location_in_source'
      def institutional_id_location_in_source
        row[INSTITUTIONAL_ID_LOCATION_IN_SOURCE]
      end
      # RECORD_LAST_UPDATED                 = 'record_last_updated'
      def record_last_updated
        row[RECORD_LAST_UPDATED]
      end
      #
      # CALL_NUMBER                         = 'call_number'
      def call_number
        row[CALL_NUMBER]
      end
      # TITLE                               = 'title'
      def title
        row[TITLE]
      end

      # IIIF_MANIFEST_URL                   = 'iiif_manifest_url'
      def iiif_manifest_url
        row[IIIF_MANIFEST_URL]
      end
      # LINK_TO_INSTITUTIONAL_RECORD        = 'link_to_institutional_record'
      def link_to_institutional_record
        row[LINK_TO_INSTITUTIONAL_RECORD]
      end
      # MANIFEST_GENERATED_AT               = 'manifest_generated_at'
      def manifest_generated_at
        row[MANIFEST_GENERATED_AT]
      end



    end
  end
end