# frozen_string_literal: true

module DS
  module Mapper

    class DSCSVMapper < DS::Mapper::BaseMapper


      def initialize(source_dir:, timestamp:)
        super(
          source_dir: source_dir,
          timestamp:  timestamp,
          source:     DS::Source::DSCSV.new,
        )
      end

      def map_record entry
        record                             = extract_record entry
        source_type                        = 'ds-csv'
        source_file                        = entry.filename
        ds_id                              = entry.ds_id
        date_added                         = ''
        date_last_updated                  = ''
        dated                              = entry.dated?
        cataloging_convention              = DS::Extractor::DsCsvExtractor.extract_cataloging_convention(record)
        holding_institution_ds_qid         = entry.institution_ds_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_date_as_recorded        = DS::Extractor::DsCsvExtractor.extract_production_date_as_recorded(record).join '|'
        production_date                    = DS::Extractor::DsCsvExtractor.extract_date_range(record, range_sep: '^').join '|'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        physical_description               = DS::Extractor::DsCsvExtractor.extract_physical_description(record).join '|'
        note                               = DS::Extractor::DsCsvExtractor.extract_notes(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated
        acknowledgments                    = DS::Extractor::DsCsvExtractor.extract_acknowledgments(record).join '|'

        {
          ds_id:                              ds_id,
          date_added:                         date_added,
          date_last_updated:                  date_last_updated,
          dated:                              dated,
          source_type:                        source_type,
          cataloging_convention:              cataloging_convention,
          holding_institution_ds_qid:         holding_institution_ds_qid,
          holding_institution_as_recorded:    holding_institution_as_recorded,
          holding_institution_id_number:      holding_institution_id_number,
          holding_institution_shelfmark:      holding_institution_shelfmark,
          link_to_holding_institution_record: link_to_holding_institution_record,
          iiif_manifest:                      iiif_manifest,
          production_date:                    production_date,
          century:                            century,
          century_aat:                        century_aat,
          production_date_as_recorded:        production_date_as_recorded,
          physical_description:               physical_description,
          note:                               note,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        source_file,
          acknowledgments:                    acknowledgments
        }.update build_term_maps DS::Extractor::DsCsvExtractor, record
      end

      def extract_record entry
        locator = DS::Extractor::CsvRecordLocator.new
        csv = source.load_source File.join(source_dir, entry.filename)
        locator.locate_record(csv, entry.institutional_id, entry.institutional_id_location_in_source).first
      end


    end
  end
end
