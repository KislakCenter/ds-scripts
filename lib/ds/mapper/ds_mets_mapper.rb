# frozen_string_literal: true

module DS
  module Mapper
    class DSMetsMapper < DS::Mapper::BaseMapper
      attr_reader :iiif_lookup
      attr_reader :ia_url_lookup


      def initialize(source_dir:, timestamp:)
        super(
          source_dir: source_dir,
          timestamp: timestamp,
          source: DS::Source::DSMetsXML.new
        )
      end

      def extract_record entry
        locator = DS::Extractor::XmlRecordLocator.new
        source_file_path = File.join source_dir, entry.filename
        xml   = source.load_source source_file_path

        record = locator.locate_record xml, entry.institutional_id, entry.institutional_id_location_in_source
        return record if record.present?

        raise "Unable to locate record for #{entry.institutional_id} (errors: #{locator.errors.join(', ')})"
      end

      ##
      # @param [DS::Manifest::Entry] entry entry instance for a manifest row
      # @return [Hash] the mapped record
      def map_record entry
        record = extract_record entry

        source_type                        = entry.source_type
        source_file                        = entry.filename
        ds_id                              = entry.ds_id
        date_added                         = nil
        date_last_updated                  = nil
        cataloging_convention              = DS::Extractor::DsMetsXmlExtractor.extract_cataloging_convention(record)
        holding_institution_ds_qid         = entry.institution_ds_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_date_as_recorded        = DS::Extractor::DsMetsXmlExtractor.extract_production_date_as_recorded(record).join '|'
        production_date                    = DS::Extractor::DsMetsXmlExtractor.extract_date_range(record, range_sep: '^').join '|'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        dated                              = DS::Extractor::DsMetsXmlExtractor.dated_by_scribe? record
        physical_description               = DS::Extractor::DsMetsXmlExtractor.extract_physical_description(record).join '|'
        note                               = DS::Extractor::DsMetsXmlExtractor.extract_notes(record).join '|'
        acknowledgments                   = DS::Extractor::DsMetsXmlExtractor.extract_acknowledgments(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated

        {
          ds_id:                              ds_id,
          date_added:                         date_added,
          date_last_updated:                  date_last_updated,
          dated:                              dated,
          cataloging_convention:              cataloging_convention,
          source_type:                        source_type,
          holding_institution_ds_qid:         holding_institution_ds_qid,
          holding_institution_as_recorded:    holding_institution_as_recorded,
          holding_institution_id_number:      holding_institution_id_number,
          holding_institution_shelfmark:      holding_institution_shelfmark,
          link_to_holding_institution_record: link_to_holding_institution_record,
          iiif_manifest:                      iiif_manifest,
          production_date_as_recorded:        production_date_as_recorded,
          production_date:                    production_date,
          century:                            century,
          century_aat:                        century_aat,
          physical_description:               physical_description,
          note:                               note,
          acknowledgments:                   acknowledgments,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        source_file,
        }.update build_term_maps DS::Extractor::DsMetsXmlExtractor, record
      end
    end
  end
end
