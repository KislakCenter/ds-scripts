module DS
  class OPennTEIConverter
    attr_reader :timestamp

    def initialize timestamp:
      @timestamp = timestamp
    end

    ##
    # @param [Nokogiri::XML::Node] xml the MARC record
    # @return [Hash]
    def convert_openn_tei xml, source_file:
      xml.remove_namespaces!

      source_type                        = 'openn-tei'
      holding_institution_as_recorded    = xml.xpath('(//msIdentifier/institution|//msIdentifier/repository)[1]').text
      holding_institution                = DS::Institutions.find_qid holding_institution_as_recorded
      holding_institution_id_number      = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/altIdentifier[@type="bibid"]/idno').text()
      holding_institution_shelfmark      = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]').text()
      link_to_holding_institution_record = xml.xpath('//altIdentifier[@type="resource"][1]').text.strip
      production_place_as_recorded       = xml.xpath('//origPlace/text()').map(&:to_s).join '|'
      production_place                   = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'structured_value'
      production_place_label             = Recon::Places.lookup production_place_as_recorded.split('|'), from_column: 'authorized_label'
      production_date_as_recorded        = DS::OPennTEI.extract_production_date xml, range_sep: '-'
      production_date                    = DS::OPennTEI.extract_production_date xml, range_sep: '^'
      century                            = DS.transform_dates_to_centuries production_date
      century_aat                        = DS.transform_centuries_to_aat century
      title_as_recorded                  = xml.xpath('//msItem[1]/title/text()').map(&:to_s).join '|'
      standard_title                     = Recon::Titles.lookup(title_as_recorded.split('|'), column: 'authorized_label').join('|')
      author_as_recorded                 = xml.xpath('//msItem/author/text()').map(&:to_s).join '|'
      author_wikidata                    = Recon::Names.lookup(author_as_recorded.split('|'), column: 'structured_value').join '|'
      author                             = ''
      author_instance_of                 = Recon::Names.lookup(author_as_recorded.split('|'), column: 'instance_of').join '|'
      author_label                       = Recon::Names.lookup(author_as_recorded.split('|'), column: 'authorized_label').join '|'
      artist_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'artist'
      artist_wikidata                    = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'structured_value').join '|'
      artist                             = ''
      artist_instance_of                 = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'instance_of').join '|'
      artist_label                       = Recon::Names.lookup(artist_as_recorded.split('|'), column: 'authorized_label').join '|'
      scribe_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'scribe'
      scribe_wikidata                    = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'structured_value').join '|'
      scribe                             = ''
      scribe_instance_of                 = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'instance_of').join '|'
      scribe_label                       = Recon::Names.lookup(scribe_as_recorded.split('|'), column: 'authorized_label').join '|'
      language_as_recorded               = DS::OPennTEI.extract_language_as_recorded xml
      language                           = Recon::Languages.lookup language_as_recorded, from_column: 'structured_value'
      language_label                     = Recon::Languages.lookup language_as_recorded, from_column: 'authorized_label'
      illuminated_initials               = ''
      miniatures                         = ''
      former_owner_as_recorded           = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'former owner'
      former_owner_wikidata              = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'structured_value').join '|'
      former_owner                       = ''
      former_owner_instance_of           = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'instance_of').join '|'
      former_owner_label                 = Recon::Names.lookup(former_owner_as_recorded.split('|'), column: 'authorized_label').join '|'
      material_as_recorded               = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p').text
      material                           = Recon::Materials.lookup material_as_recorded.split('|'), column: 'structured_value'
      material_label                     = Recon::Materials.lookup material_as_recorded.split('|'), column: 'authorized_label'
      physical_description               = DS::OPennTEI.extract_physical_description xml
      acknowledgements                   = ''
      binding_description                = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()').text
      folios                             = ''
      extent_as_recorded                 = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text.strip
      dimensions                         = ''
      dimensions_as_recorded             = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text.strip
      decoration                         = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()').text
      note                               = DS::OPennTEI.extract_note(xml).join '|'
      data_processed_at                  = timestamp
      data_source_modified               = DS::OPennTEI.source_modified xml

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
        binding:                            binding_description,
        folios:                             folios,
        extent_as_recorded:                 extent_as_recorded,
        dimensions:                         dimensions,
        dimensions_as_recorded:             dimensions_as_recorded,
        decoration:                         decoration,
        note:                               note,
        data_processed_at:                  data_processed_at,
        data_source_modified:               data_source_modified,
        source_file:                        source_file,
      }
    end

  end
end