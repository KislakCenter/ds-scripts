# frozen_string_literal: true

module DS
  module Mapper
    class MarcMapper
      attr_reader :manifest_entry
      attr_reader :record
      attr_reader :inst_qid
      attr_reader :inst_code
      attr_reader :preferred_name
      attr_reader :holdings_file
      attr_reader :timestamp
      attr_reader :source_file
      attr_reader :source_file
      attr_reader :iiif_manifest_url
      attr_reader :institutional_id
      attr_reader :call_number
      attr_reader :link_to_institutional_record

      ##
      # @param [DS::Manifest:Entry] manifest_entry the manifest line
      #        item for this record
      # @param [Nokogiri::XML::Node] record the MARC XML record node
      # @param [Date] timestamp for this import CSV
      def initialize(manifest_entry:, record:, timestamp:)
        @record                       = record
        @manifest_entry               = manifest_entry
        @inst_qid                     = manifest_entry.institution_wikidata_qid
        @preferred_name               = manifest_entry.institution_wikidata_label
        @timestamp                    = timestamp
        @source_file                  = manifest_entry.filename
        @iiif_manifest_url            = manifest_entry.iiif_manifest_url
        @institutional_id             = manifest_entry.institutional_id
        @call_number                  = manifest_entry.call_number
        @link_to_institutional_record = manifest_entry.link_to_institutional_record
      end

      def map_record
        source_type                        = 'marc-xml'
        cataloging_convention              = DS::MarcXML.extract_cataloging_convention record
        holding_institution                = inst_qid
        holding_institution_as_recorded    = preferred_name
        holding_institution_id_number      = DS::MarcXML.extract_001_control_number record
        holding_institution_shelfmark      = call_number
        link_to_holding_institution_record = link_to_institutional_record
        iiif_manifest                      = iiif_manifest_url
        production_date_encoded_008        = DS::MarcXML.extract_encoded_date_008 record
        production_date                    = DS::MarcXML.parse_008 production_date_encoded_008, range_sep: '^'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        production_place_as_recorded       = DS::MarcXML.extract_place_as_recorded(record).join '|'
        production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
        production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
        production_date_as_recorded        = DS::MarcXML.extract_date_as_recorded record
        uniform_title_as_recorded          = DS::MarcXML.extract_uniform_title_as_recorded record
        uniform_title_agr                  = DS::MarcXML.extract_uniform_title_agr record
        title_as_recorded                  = DS::MarcXML.extract_title_as_recorded record
        title_as_recorded_agr              = DS::MarcXML.extract_title_agr record, 245
        standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
        genre_as_recorded                  = DS::MarcXML.extract_genre_as_recorded(record, sub2: :all, sub_sep: '--', uniq: true).join('|')
        genre_vocabulary                   = DS::MarcXML.extract_genre_vocabulary record
        genre                              = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'structured_value'
        genre_label                        = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'authorized_label'
        subject_as_recorded                = DS::MarcXML.extract_subject_as_recorded(record).join '|'
        subject                            = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'structured_value'
        subject_label                      = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'authorized_label'
        author_as_recorded                 = DS::MarcXML.extract_authors_as_recorded(record).join '|'
        author_as_recorded_agr             = DS::MarcXML.extract_authors_as_recorded_agr(record).join '|'
        author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
        author                             = ''
        author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
        author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
        artist_as_recorded                 = DS::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711], relators: ['artist', 'illuminator']).join '|'
        artist_as_recorded_agr             = DS::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711], relators: ['artist', 'illuminator']).join '|'
        artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
        artist                             = ''
        artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
        artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
        scribe_as_recorded                 = DS::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711], relators: ['scribe']).join '|'
        scribe_as_recorded_agr             = DS::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711], relators: ['scribe']).join '|'
        scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
        scribe                             = ''
        scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
        scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
        language_as_recorded               = DS::MarcXML.extract_language_as_recorded record
        language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
        language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
        former_owner_as_recorded           = DS::MarcXML.extract_names_as_recorded(record,      tags: [700, 710, 711, 790, 791], relators: ['former owner']).join '|'
        former_owner_as_recorded_agr       = DS::MarcXML.extract_names_as_recorded_agr(record,  tags: [700, 710, 711, 790, 791], relators: ['former owner']).join '|'
        former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
        former_owner                       = ''
        former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
        former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
        material_as_recorded               = DS::MarcXML.collect_datafields(record, tags: 300, codes: 'b').join '|'
        material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
        material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
        physical_description               = DS::MarcXML.extract_physical_description(record).join('|')
        note                               = DS::MarcXML.extract_note(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = DS::MarcXML.source_modified record

        { source_type:                        source_type,
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