# frozen_string_literal: true

module DS
  module Mapper
    class OPennTEIMapper < BaseMapper

      def extract_record entry
        xml = find_or_open_source entry
        xpath = "//TEI[./teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno/text() = '#{entry.institutional_id}']"
        xml.at_xpath xpath
      end

      def open_source entry
        source_file_path = File.join source_dir, entry.filename
        xml_string = File.open(source_file_path).read
        xml = Nokogiri::XML xml_string
        xml.remove_namespaces!
      end

      def map_record entry
        record = extract_record entry
        source_type                        = 'tei-xml'
        ds_id                              = entry.ds_id
        holding_institution                = entry.institution_wikidata_qid
        holding_institution_as_recorded    = entry.institution_wikidata_label
        holding_institution_id_number      = entry.institutional_id
        holding_institution_shelfmark      = entry.call_number
        link_to_holding_institution_record = entry.link_to_institutional_record
        iiif_manifest                      = entry.iiif_manifest_url
        production_date_as_recorded        = DS::OPennTEI.extract_production_date record, range_sep: '-'
        production_date                    = DS::OPennTEI.extract_production_date record, range_sep: '^'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        production_place_as_recorded       = DS::OPennTEI.extract_production_place(record).join '|'
        production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
        production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
        title_as_recorded                  = DS::OPennTEI.extract_title_as_recorded(record).join '|'
        title_as_recorded_agr              = DS::OPennTEI.extract_title_as_recorded_agr(record).join '|'
        uniform_title_as_recorded          = ''
        uniform_title_agr                  = ''
        standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
        genre_as_recorded                  = DS::OPennTEI.extract_genre_as_recorded(record).join '|'
        genre_vocabulary                   = ''
        genre                              = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'structured_value'
        genre_label                        = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'authorized_label'
        subject_as_recorded                = DS::OPennTEI.extract_subject_as_recorded(record).join '|'
        subject                            = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'structured_value'
        subject_label                      = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'authorized_label'
        author_as_recorded                 = DS::OPennTEI.extract_authors_as_recorded(record).join '|'
        author_as_recorded_agr             = DS::OPennTEI.extract_authors_agr(record).join '|'
        author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
        author                             = ''
        author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
        author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
        artist_as_recorded                 = DS::OPennTEI.extract_artists_as_recorded(record).join '|'
        artist_as_recorded_agr             = DS::OPennTEI.extract_artists_agr(record).join '|'
        artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
        artist                             = ''
        artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
        artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
        scribe_as_recorded                 = DS::OPennTEI.extract_scribes_as_recorded(record).join '|'
        scribe_as_recorded_agr             = DS::OPennTEI.extract_scribes_agr(record).join '|'
        scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
        scribe                             = ''
        scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
        scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
        language_as_recorded               = DS::OPennTEI.extract_language_as_recorded record
        language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
        language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
        former_owner_as_recorded           = DS::OPennTEI.extract_former_owners_as_recorded(record).join '|'
        former_owner_as_recorded_agr       = DS::OPennTEI.extract_former_owners_agr(record).join '|'
        former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
        former_owner                       = ''
        former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
        former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
        material_as_recorded               = DS::OPennTEI.extract_material_as_recorded(record).join '|'
        material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
        material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
        acknowledgements                   = DS::OPennTEI.extract_acknowledgments(record).join '|'
        physical_description               = DS::OPennTEI.extract_physical_description record
        note                               = DS::OPennTEI.extract_note(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = entry.record_last_updated


        # TODO: BiblioPhilly MSS have keywords (not subjects, genre); include them?

        {
          ds_id:                              ds_id,
          date_added:                         nil,
          date_last_updated:                  nil,
          cataloging_convention:              nil,
          dated:                              nil,
          source_type:                        source_type,
          holding_institution:                holding_institution,
          holding_institution_as_recorded:    holding_institution_as_recorded,
          holding_institution_id_number:      holding_institution_id_number,
          holding_institution_shelfmark:      holding_institution_shelfmark,
          link_to_holding_institution_record: link_to_holding_institution_record,
          iiif_manifest:                      iiif_manifest,
          production_date_as_recorded:        production_date_as_recorded,
          production_date:                    production_date,
          century:                            century,
          century_aat:                        century_aat,
          production_place_as_recorded:       production_place_as_recorded,
          production_place:                   production_place,
          production_place_label:             production_place_label,
          title_as_recorded:                  title_as_recorded,
          title_as_recorded_agr:              title_as_recorded_agr,
          uniform_title_as_recorded:          uniform_title_as_recorded,
          uniform_title_agr:                  uniform_title_agr,
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
          associated_agent_as_recorded:       nil,
          associated_agent_as_recorded_agr:   nil,
          associated_agent:                   nil,
          associated_agent_label:             nil,
          associated_agent_wikidata:          nil,
          associated_agent_instance_of:       nil,
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
          acknowledgements:                   acknowledgements,
          note:                               note,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        entry.filename
        }
      end
    end
  end
end