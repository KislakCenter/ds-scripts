# frozen_string_literal: true

require_relative './constants'
module DS
  module Manifest
    ##
    # The manifest Entry provides information to validate delivered data
    # and to drive the data extraction process. Specifically, each
    # line of the manifest:
    #
    # 1. Provides information often not present in standard a location
    #    in the source record, like shelfmark, source type (MARC XML,
    #    TEI XML, etc.), link to a IIIF manifest, and link to the
    #    institution's record in an OPAC or on the institution's
    #    website
    #
    # 2. Gives the file name for the record present in the delivered
    #    set of records
    #
    # 3. Provides information needed to validate the source record:
    #    its presence in the delivered data, correspondence of the
    #    source file(s) to identifying information, etc.)
    #
    #
    class Entry
      include DS::Manifest::Constants

      attr_reader :row
      attr_reader :manifest
      ##
      # @param [CSV::Row] row a manifest CSV row
      # @param [DS::Manifest::Manifest] manifest the parent manifest
      def initialize row, manifest
        @row = row
        @manifest = manifest
      end

      def [] key
        row[key]
      end

      def institution_ds_qid
        row[INSTITUTION_DS_QID]
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

      # DATED                               = 'dated'
      def dated
        row[DATED]
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
        return '' unless row[IIIF_MANIFEST_URL]
        # there may be multiple manifests; split & join with pipes
        row[IIIF_MANIFEST_URL].split(%r{[ |]}).join('|')
      end
      # LINK_TO_INSTITUTIONAL_RECORD        = 'link_to_institutional_record'
      def link_to_institutional_record
        row[LINK_TO_INSTITUTIONAL_RECORD]
      end
      # MANIFEST_GENERATED_AT               = 'manifest_generated_at'
      def manifest_generated_at
        row[MANIFEST_GENERATED_AT]
      end

      def manifest_path
        manifest.present? && manifest.path
      end

      def dated?
        dated.to_s.strip.downcase == 'true'
      end

      def to_h
        {
          institution_ds_qid:           institution_ds_qid,
          institution_wikidata_label:   institution_wikidata_label,
          ds_id:                        ds_id,
          call_number:                  call_number,
          institutional_id:             institutional_id,
          title:                        title,
          link_to_institutional_record: link_to_institutional_record,
          iiif_manifest_url:            iiif_manifest_url,
          record_last_updated:          record_last_updated,
          source_type:                  source_type,
          filename:                     filename,
          dated:                        dated?,
          manifest_generated_at:        manifest_generated_at,
        }
      end

    end
  end
end
