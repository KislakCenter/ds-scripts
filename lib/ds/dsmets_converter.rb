module DS
  class DSMETSConverter
    attr_reader :timestamp

    def initialize timestamp:
      @timestamp = timestamp
    end

    ##
    # @param [Nokogiri::XML::Node] xml the MARC record
    # @return [Hash]
    def convert xml, source_file:
      source_type                        = 'digital-scriptorium'
      holding_institution_as_recorded    = DS::DS10.extract_institution_name xml
      holding_institution                = DS::Institutions.find_qid holding_institution_as_recorded
      holding_institution_id_number      = ''
      holding_institution_shelfmark      = DS::DS10.extract_shelfmark xml
      link_to_holding_institution_record = DS::DS10.extract_link_to_inst_record xml
      production_place_as_recorded       = DS::DS10.extract_production_place xml
      production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
      production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
      production_date_as_recorded        = DS::DS10.extract_date_as_recorded xml
      production_date                    = DS::DS10.transform_production_date xml
      century                            = DS.transform_dates_to_centuries production_date
      century_aat                        = DS.transform_centuries_to_aat century
      dated                              = DS::DS10.dated_by_scribe? xml
      uniform_title_as_recorded          = ''
      uniform_title_agr                  = ''
      title_as_recorded                  = DS::DS10.extract_title xml
      title_as_recorded_agr              = ''
      standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
      genre_as_recorded                  = ''
      subject_as_recorded                = ''
      author_as_recorded                 = DS::DS10.extract_text_name xml, 'author'
      author_as_recorded_agr             = ''
      author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
      author                             = ''
      author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
      author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
      artist_as_recorded                 = DS::DS10.extract_part_name xml, 'artist'
      artist_as_recorded_agr             = ''
      artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
      artist                             = ''
      artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
      artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
      scribe_as_recorded                 = DS::DS10.extract_part_name xml, 'scribe'
      scribe_as_recorded_agr             = ''
      scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
      scribe                             = ''
      scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
      scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
      language_as_recorded               = DS::DS10.extract_language xml
      language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
      language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
      former_owner_as_recorded           = DS::DS10.extract_ownership xml
      former_owner_as_recorded_agr       = ''
      # TODO: Legacy XML doesn't have former owner names; the following can't be tested
      former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
      former_owner                       = ''
      former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
      former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
      material_as_recorded               = DS::DS10.extract_support xml
      material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
      material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
      physical_description               = DS::DS10.extract_physical_description xml
      note                               = DS::DS10.extract_note(xml).join '|'
      acknowledgements                   = DS::DS10.extract_acknowledgements xml
      data_processed_at                  = timestamp
      data_source_modified               = DS::DS10.source_modified

      { source_type:                        source_type,
        holding_institution:                holding_institution,
        holding_institution_as_recorded:    holding_institution_as_recorded,
        holding_institution_id_number:      holding_institution_id_number,
        holding_institution_shelfmark:      holding_institution_shelfmark,
        link_to_holding_institution_record: link_to_holding_institution_record,
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
        subject_as_recorded:                subject_as_recorded,
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
        acknowledgements:                   acknowledgements,
        data_processed_at:                  data_processed_at,
        data_source_modified:               data_source_modified,
        source_file:                        source_file,
      }
    end

  end
end