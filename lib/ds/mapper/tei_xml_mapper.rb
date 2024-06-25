# frozen_string_literal: true

module DS
  module Mapper
    class TeiXmlMapper < BaseMapper

      def initialize source_dir:, timestamp:
        super(
          source_dir: source_dir,
          timestamp: timestamp,
          source: DS::Source::TeiXML.new
        )
      end

      def extract_record entry
        locator = DS::Extractor::XmlRecordLocator.new
        source_file_path = File.join source_dir, entry.filename
        xml = source.load_source source_file_path
        record = locator.locate_record xml, entry.institutional_id, entry.institutional_id_location_in_source
        return record if record.present?

        raise "Unable to locate record for #{entry.institutional_id} (errors: #{record_locator.errors.join(', ')})"
      end

      def map_record entry
        record                             = extract_record entry
        source_type                        = 'tei-xml'
        ds_id                              = entry.ds_id
        date_added                         = ''
        date_last_updated                  = ''
        cataloging_convention              = DS::Extractor::TeiXml.extract_cataloging_convention(record)
        dated                              = ''
        holding_institution_ds_qid         = entry.institution_ds_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_date_as_recorded        = DS::Extractor::TeiXml.extract_production_date_as_recorded(record, range_sep: '-').join('|')
        production_date                    = DS::Extractor::TeiXml.extract_date_range(record, range_sep: '^').join('|')
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        acknowledgments                    = DS::Extractor::TeiXml.extract_acknowledgments(record).join '|'
        physical_description               = DS::Extractor::TeiXml.extract_physical_description(record).join '|'
        note                               = DS::Extractor::TeiXml.extract_notes(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated


        # TODO: BiblioPhilly MSS have keywords (not subjects, genre); include them?

        data  = {
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
          acknowledgments:                    acknowledgments,
          note:                               note,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        entry.filename
        }
        data.update build_term_maps DS::Extractor::TeiXml, record
      end
    end
  end
end
