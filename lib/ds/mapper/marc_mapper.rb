# frozen_string_literal: true

module DS
  module Mapper

    class MarcMapper < DS::Mapper::BaseMapper

      def initialize(source_dir:, timestamp:)
        super(
          source_dir: source_dir,
          timestamp: timestamp,
          source: DS::Source::MarcXML.new
        )
      end
      ##
      # @param [DS::Manifest::Entry] entry +entry+ representing one
      #     row in a manifest
      def extract_record entry
        record_locator = DS::Extractor::XmlRecordLocator.new(
          namespaces: DS::Constants::XML_NAMESPACES
        )

        source_file_path = File.join source_dir, entry.filename
        xml = source.load_source source_file_path
        xpath = entry.institutional_id_location_in_source.gsub('ID_PLACEHOLDER', entry.institutional_id) # "//record[#{entry.institutional_id_location_in_source} = '#{entry.institutional_id}']"
        record = record_locator.locate_record(xml, entry.institutional_id, xpath).first
        return record if record.present?

        raise "Unable to locate record for #{entry.institutional_id} (errors: #{record_locator.errors.join(', ')})"
      end

      ##
      # @param [DS::Manifest::Entry] entry entry instance for a manifest row
      # @return [Hash] the mapped record
      def map_record entry
        record = extract_record entry
        source_type                        = 'marc-xml'
        source_file                        = entry.filename
        ds_id                              = entry.ds_id
        date_added                         = ''
        date_last_updated                  = ''
        dated                              = ''
        cataloging_convention              = DS::Extractor::MarcXmlExtractor.extract_cataloging_convention record
        holding_institution                = entry.institution_wikidata_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_date_as_recorded        = DS::Extractor::MarcXmlExtractor.extract_production_date_as_recorded(record).join '|'
        production_date                    = DS::Extractor::MarcXmlExtractor.extract_date_range(record, range_sep: '^').join '|'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        physical_description               = DS::Extractor::MarcXmlExtractor.extract_physical_description(record).join('|')
        note                               = DS::Extractor::MarcXmlExtractor.extract_notes(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated
        acknowledgments                   = ''

        data = {
          ds_id:                              ds_id,
          date_added:                         date_added,
          date_last_updated:                  date_last_updated,
          dated:                              dated,
          source_type:                        source_type,
          cataloging_convention:              cataloging_convention,
          holding_institution:                holding_institution,
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
          acknowledgments:                   acknowledgments,
        }.update build_term_maps DS::Extractor::MarcXmlExtractor, record
      end
    end
  end
end
