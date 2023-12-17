# frozen_string_literal: true

module DS
  module Mapper

    class MarcMapper < DS::Mapper::BaseMapper

      ##
      # @param [DS::Manifest::Entry] entry +entry+ representing one
      #     row in a manifest
      def extract_record entry
        xml = find_or_open_source entry
        xpath = "//record[./controlfield[@tag='001' and ./text() = '#{entry.institutional_id}']]"
        xml.at_xpath xpath
      end

      def open_source entry
        source_file_path = File.join source_dir, entry.filename
        xml_string = File.open(source_file_path).read
        xml = Nokogiri::XML xml_string
        xml.remove_namespaces!
        xml
      end

      ##
      # @param [DS::Manifest::Entry] entry entry instance for a manifest row
      # @return [Hash] the mapped record
      def map_record entry
        record = extract_record entry
        source_type                        = 'marc-xml'
        source_file                        = entry.filename
        ds_id                              = entry.ds_id
        cataloging_convention              = DS::Extractor::MarcXML.extract_cataloging_convention record
        holding_institution                = entry.institution_wikidata_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = DS::Extractor::MarcXML.extract_001_control_number record
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        uniform_title_as_recorded          = DS::Extractor::MarcXML.extract_uniform_title_as_recorded record
        uniform_title_agr                  = DS::Extractor::MarcXML.extract_uniform_title_agr record
        title_as_recorded                  = DS::Extractor::MarcXML.extract_title_as_recorded record
        title_as_recorded_agr              = DS::Extractor::MarcXML.extract_title_agr record, 245
        standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
        production_date_encoded_008        = DS::Extractor::MarcXML.extract_encoded_date_008 record
        production_date_as_recorded        = DS::Extractor::MarcXML.extract_date_as_recorded record
        production_date                    = DS::Extractor::MarcXML.parse_008 production_date_encoded_008, range_sep: '^'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        production_place_as_recorded       = DS::Extractor::MarcXML.extract_place_as_recorded(record).join '|'
        production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
        production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
        genre_as_recorded                  = DS::Extractor::MarcXML.extract_genre_as_recorded(record, sub2: :all, sub_sep: '--', uniq: true).join('|')
        genre_vocabulary                   = DS::Extractor::MarcXML.extract_genre_vocabulary(record).join '|'
        genre                              = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'structured_value'
        genre_label                        = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'authorized_label'
        subject_as_recorded                = DS::Extractor::MarcXML.extract_subject_as_recorded(record).join '|'
        subject                            = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'structured_value'
        subject_label                      = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'authorized_label'
        author_as_recorded                 = DS::Extractor::MarcXML.extract_authors_as_recorded(record).join '|'
        author_as_recorded_agr             = DS::Extractor::MarcXML.extract_authors_as_recorded_agr(record).join '|'
        author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
        author                             = ''
        author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
        author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
        artist_as_recorded                 = DS::Extractor::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711], relators: ['artist', 'illuminator']).join '|'
        artist_as_recorded_agr             = DS::Extractor::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711], relators: ['artist', 'illuminator']).join '|'
        artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
        artist                             = ''
        artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
        artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
        scribe_as_recorded                 = DS::Extractor::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711], relators: ['scribe']).join '|'
        scribe_as_recorded_agr             = DS::Extractor::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711], relators: ['scribe']).join '|'
        scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
        scribe                             = ''
        scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
        scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
        language_as_recorded               = DS::Extractor::MarcXML.extract_language_as_recorded record
        language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
        language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
        former_owner_as_recorded           = DS::Extractor::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711, 790, 791], relators: ['former owner']).join '|'
        former_owner_as_recorded_agr       = DS::Extractor::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711, 790, 791], relators: ['former owner']).join '|'
        former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
        former_owner                       = ''
        former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
        former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
        material_as_recorded               = DS::Extractor::MarcXML.collect_datafields(record, tags: 300, codes: 'b').join '|'
        material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
        material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
        physical_description               = DS::Extractor::MarcXML.extract_physical_description(record).join('|')
        note                               = DS::Extractor::MarcXML.extract_note(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = DS::Extractor::MarcXML.source_modified record

        {
          ds_id:                              ds_id,
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
          production_place_as_recorded:       production_place_as_recorded,
          production_place:                   production_place,
          production_place_label:             production_place_label,
          production_date_as_recorded:        production_date_as_recorded,
          uniform_title_as_recorded:          uniform_title_as_recorded,
          uniform_title_agr:                  uniform_title_agr,
          title_as_recorded:                  title_as_recorded,
          title_as_recorded_agr:              title_as_recorded_agr,
          standard_title:                     standard_title,
          genre_as_recorded:                  genre_as_recorded,
          genre:                              genre,
          genre_label:                        genre_label,
          subject_as_recorded:                subject_as_recorded,
          subject:                            subject,
          subject_label:                      subject_label,
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
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        source_file
        }
      end
    end
  end
end