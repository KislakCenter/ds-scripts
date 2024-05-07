# frozen_string_literal: true

module DS
  module Mapper
    class DSMetsMapper < DS::Mapper::BaseMapper
      attr_reader :xml
      attr_reader :timestamp
      attr_reader :iiif_lookup
      attr_reader :ia_url_lookup
      attr_reader :source_file

      def extract_record entry
        xml = find_or_open_source entry
        xpath = "/mets:mets[./mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type = 'local' and ./text() = '#{entry.institutional_id}']]"
        xml.at_xpath xpath
      end

      def open_source entry
        source_file_path = File.join source_dir, entry.filename
        File.open(source_file_path) { |f| Nokogiri::XML f }
      end

      ##
      # @param [DS::Manifest::Entry] entry entry instance for a manifest row
      # @return [Hash] the mapped record
      def map_record entry
        record = extract_record entry

        source_type                        = entry.source_type
        source_file                        = entry.filename
        ds_id                              = entry.ds_id
        holding_institution                = entry.institution_wikidata_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_place_as_recorded       = DS::DsMetsXml.extract_production_places_as_recorded(record).join '|'
        production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
        production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
        production_date_as_recorded        = DS::DsMetsXml.extract_production_date_as_recorded record
        production_date                    = DS::DsMetsXml.transform_production_date record
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        dated                              = DS::DsMetsXml.dated_by_scribe? record
        uniform_title_as_recorded          = ''
        uniform_title_agr                  = ''
        title_as_recorded                  = DS::DsMetsXml.extract_titles_as_recorded(record).join '|'
        title_as_recorded_agr              = ''
        standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
        genre_as_recorded                  = ''
        subject_as_recorded                = DS::DsMetsXml.extract_all_subjects_as_recorded(record).join '|'
        author_as_recorded                 = DS::DsMetsXml.extract_authors_as_recorded(record).join '|'
        author_as_recorded_agr             = ''
        author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
        author                             = ''
        author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
        author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
        artist_as_recorded                 = DS::DsMetsXml.extract_artists_as_recorded(record).join '|'
        artist_as_recorded_agr             = ''
        artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
        artist                             = ''
        artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
        artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
        scribe_as_recorded                 = DS::DsMetsXml.extract_scribes_as_recorded(record).join '|'
        scribe_as_recorded_agr             = ''
        scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
        scribe                             = ''
        scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
        scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
        associated_agent_as_recorded       = DS::DsMetsXml.extract_other_names_as_recorded(record).join '|'
        associated_agent_as_recorded_agr   = ''
        associated_agent_wikidata          = Recon::Names.lookup(associated_agent_as_recorded.split('|'), column: 'structured_value').join '|'
        associated_agent                   = ''
        associated_agent_instance_of       = Recon::Names.lookup(associated_agent_as_recorded.split('|'), column: 'instance_of').join '|'
        associated_agent_label             = Recon::Names.lookup(associated_agent_as_recorded.split('|'), column: 'authorized_label').join '|'
        language_as_recorded               = DS::DsMetsXml.extract_languages_as_recorded(record).join '|'
        language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
        language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
        former_owner_as_recorded           = DS::DsMetsXml.extract_former_owners_as_recorded(record).join '|'
        former_owner_as_recorded_agr       = ''
        # TODO: Legacy XML doesn't have former owner names; the following can't be tested
        former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
        former_owner                       = ''
        former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
        former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
        material_as_recorded               = DS::DsMetsXml.extract_material_as_recorded record
        material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
        material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
        physical_description               = DS::DsMetsXml.extract_physical_description(record).join '|'
        note                               = DS::DsMetsXml.extract_notes(record).join '|'
        acknowledgements                   = DS::DsMetsXml.extract_acknowledgments(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated

        {
          ds_id:                              ds_id,
          date_added:                         nil,
          date_last_updated:                  nil,
          cataloging_convention:              nil,
          source_type:                        source_type,
          holding_institution:                holding_institution,
          holding_institution_as_recorded:    holding_institution_as_recorded,
          holding_institution_id_number:      holding_institution_id_number,
          holding_institution_shelfmark:      holding_institution_shelfmark,
          link_to_holding_institution_record: link_to_holding_institution_record,
          iiif_manifest:                      iiif_manifest,
          production_date:                    production_date,
          production_place_as_recorded:       production_place_as_recorded,
          production_place:                   production_place,
          production_place_label:             production_place_label,
          century:                            century,
          century_aat:                        century_aat,
          production_date_as_recorded:        production_date_as_recorded,
          dated:                              dated,
          uniform_title_as_recorded:          uniform_title_as_recorded,
          uniform_title_agr:                  uniform_title_agr,
          title_as_recorded:                  title_as_recorded,
          title_as_recorded_agr:              title_as_recorded_agr,
          standard_title:                     standard_title,
          genre_as_recorded:                  genre_as_recorded,
          genre:                              nil,
          genre_label:                        nil,
          subject_as_recorded:                subject_as_recorded,
          subject:                            nil,
          subject_label:                      nil,
          author_as_recorded:                 author_as_recorded,
          author_as_recorded_agr:             author_as_recorded_agr,
          author_wikidata:                    author_wikidata,
          author:                             author,
          author_instance_of:                 author_instance_of,
          author_label:                       author_label,
          artist_as_recorded:                 artist_as_recorded,
          artist_as_recorded_agr:             artist_as_recorded_agr,
          artist_wikidata:                    artist_wikidata,
          artist:                             artist,
          artist_instance_of:                 artist_instance_of,
          artist_label:                       artist_label,
          scribe_as_recorded:                 scribe_as_recorded,
          scribe_as_recorded_agr:             scribe_as_recorded_agr,
          scribe_wikidata:                    scribe_wikidata,
          scribe:                             scribe,
          scribe_instance_of:                 scribe_instance_of,
          scribe_label:                       scribe_label,
          associated_agent_as_recorded:       associated_agent_as_recorded,
          associated_agent_as_recorded_agr:   associated_agent_as_recorded_agr,
          associated_agent_wikidata:          associated_agent_wikidata,
          associated_agent:                   associated_agent,
          associated_agent_instance_of:       associated_agent_instance_of,
          associated_agent_label:             associated_agent_label,
          language_as_recorded:               language_as_recorded,
          language:                           language,
          language_label:                     language_label,
          former_owner_as_recorded:           former_owner_as_recorded,
          former_owner_as_recorded_agr:       former_owner_as_recorded_agr,
          former_owner_wikidata:              former_owner_wikidata,
          former_owner:                       former_owner,
          former_owner_instance_of:           former_owner_instance_of,
          former_owner_label:                 former_owner_label,
          material_as_recorded:               material_as_recorded,
          material:                           material,
          material_label:                     material_label,
          physical_description:               physical_description,
          note:                               note,
          acknowledgements:                   acknowledgements,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        source_file,
        }
      end
    end
  end
end
