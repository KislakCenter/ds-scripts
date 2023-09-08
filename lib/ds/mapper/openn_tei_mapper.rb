# frozen_string_literal: true

module DS
  module Mapper
    class OPennTEIMapper
      attr_reader :timestamp
      attr_reader :source_file
      attr_reader :record

      def initialize(record:, timestamp:, source_file:)
        @record         = record
        @timestamp      = timestamp
        @source_file    = source_file
      end

      def map_record
        source_type                        = 'openn-tei'
        holding_institution_as_recorded    = record.xpath('(//msIdentifier/institution|//msIdentifier/repository)[1]').text
        holding_institution                = DS::Institutions.find_qid holding_institution_as_recorded
        holding_institution_id_number      = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/altIdentifier[@type="bibid"]/idno').text()
        holding_institution_shelfmark      = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]').text()
        link_to_holding_institution_record = record.xpath('//altIdentifier[@type="resource"][1]').text.strip
        production_place_as_recorded       = record.xpath('//origPlace/text()').map(&:to_s).join '|'
        production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
        production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
        production_date_as_recorded        = DS::OPennTEI.extract_production_date record, range_sep: '-'
        production_date                    = DS::OPennTEI.extract_production_date record, range_sep: '^'
        century                            = DS.transform_dates_to_centuries production_date
        century_aat                        = DS.transform_centuries_to_aat century
        title_as_recorded                  = record.xpath('//msItem[1]/title/text()').map(&:to_s).join '|'
        standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
        genre_as_recorded                  = DS::OPennTEI.extract_genre_as_recorded(record).join '|'
        genre_vocabulary                   = '' # DS::OPennTEI.extract_genre_vocabulary record
        genre                              = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'structured_value'
        genre_label                        = Recon::Genres.lookup genre_as_recorded.split('|'), genre_vocabulary.split('|'), from_column: 'authorized_label'
        subject_as_recorded                = DS::OPennTEI.extract_subject_as_recorded(record).join '|'
        subject                            = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'structured_value'
        subject_label                      = Recon::AllSubjects.lookup subject_as_recorded.split('|'), from_column: 'authorized_label'

        author_as_recorded                 = record.xpath('//msItem/author/text()').map(&:to_s).join '|'
        author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
        author                             = ''
        author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
        author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
        artist_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: record.xpath('//msContents/msItem'), types: 'artist'
        artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
        artist                             = ''
        artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
        artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
        scribe_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: record.xpath('//msContents/msItem'), types: 'scribe'
        scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
        scribe                             = ''
        scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
        scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
        language_as_recorded               = DS::OPennTEI.extract_language_as_recorded record
        language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
        language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
        illuminated_initials               = ''
        miniatures                         = ''
        former_owner_as_recorded           = DS::OPennTEI.extract_resp_names nodes: record.xpath('//msContents/msItem'), types: 'former owner'
        former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
        former_owner                       = ''
        former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
        former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
        material_as_recorded               = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p').text
        material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
        material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
        physical_description               = DS::OPennTEI.extract_physical_description record
        acknowledgements                   = ''
        binding_description                = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()').text
        folios                             = ''
        extent_as_recorded                 = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text.strip
        dimensions                         = ''
        dimensions_as_recorded             = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text.strip
        decoration                         = record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()').text
        note                               = DS::OPennTEI.extract_note(record).join '|'
        data_processed_at                  = timestamp
        data_source_modified               = DS::OPennTEI.source_modified record

        # TODO: BiblioPhilly MSS have keywords (not subjects, genre); include them?

        {
          source_type:                        source_type,
          holding_institution:                holding_institution,
          holding_institution_as_recorded:    holding_institution_as_recorded,
          holding_institution_id_number:      holding_institution_id_number,
          holding_institution_shelfmark:      holding_institution_shelfmark,
          link_to_holding_institution_record: link_to_holding_institution_record,
          production_place_as_recorded:       production_place_as_recorded,
          production_place:                   production_place,
          production_place_label:             production_place_label,
          production_date_as_recorded:        production_date_as_recorded,
          production_date:                    production_date,
          century:                            century,
          century_aat:                        century_aat,
          title_as_recorded:                  title_as_recorded,
          standard_title:                     standard_title,
          genre_as_recorded:                  genre_as_recorded,
          genre:                              genre,
          genre_label:                        genre_label,
          subject_as_recorded:                subject_as_recorded,
          subject:                            subject,
          subject_label:                      subject_label,
          author_as_recorded:                 author_as_recorded,
          author_wikidata:                    author_wikidata,
          author:                             author,
          author_instance_of:                 author_instance_of,
          author_label:                       author_label,
          artist_as_recorded:                 artist_as_recorded,
          artist_wikidata:                    artist_wikidata,
          artist:                             artist,
          artist_instance_of:                 artist_instance_of,
          artist_label:                       artist_label,
          scribe_as_recorded:                 scribe_as_recorded,
          scribe_wikidata:                    scribe_wikidata,
          scribe:                             scribe,
          scribe_instance_of:                 scribe_instance_of,
          scribe_label:                       scribe_label,
          language_as_recorded:               language_as_recorded,
          language:                           language,
          language_label:                     language_label,
          illuminated_initials:               illuminated_initials,
          miniatures:                         miniatures,
          former_owner_as_recorded:           former_owner_as_recorded,
          former_owner_wikidata:              former_owner_wikidata,
          former_owner:                       former_owner,
          former_owner_instance_of:           former_owner_instance_of,
          former_owner_label:                 former_owner_label,
          material:                           material,
          material_as_recorded:               material_as_recorded,
          material_label:                     material_label,
          physical_description:               physical_description,
          acknowledgements:                   acknowledgements,
          # TODO: move binding_description to physical_description
          binding:                            binding_description,
          # TODO: move folios? to physical_description
          # QUESTION: How is folios different from extent?
          folios:                             folios,
          # TODO: move extent_as_recorded to physical_description
          extent_as_recorded:                 extent_as_recorded,
          # TODO: move dimensions to physical_description
          dimensions:                         dimensions,
          # TODO: move dimensions_as_recorded to physical_description
          dimensions_as_recorded:             dimensions_as_recorded,
          # TODO: move decoration to physical_description
          decoration:                         decoration,
          note:                               note,
          data_processed_at:                  data_processed_at,
          data_source_modified:               data_source_modified,
          source_file:                        source_file,
        }
      end
    end
  end
end