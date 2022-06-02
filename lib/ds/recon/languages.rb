module Recon
  class Languages
    def self.add_recon_values rows
      rows.each do |row|
        lang = row.first
        row << Recon.look_up('languages', value: lang, column: 'authorized_label')
        row << Recon.look_up('languages', value: lang, column: 'structured_value')
      end
    end

    def self.lookup languages, from_column: 'structured_value'
      clean_languages = DS.clean_string languages, terminator: ''
      Recon.look_up('languages', value: clean_languages, column: from_column)
    end

    ##
    # Extract all the codes from the pairs of language_as_recorded and code
    # value in +data+, and add each code to data, e.g., +lat+, as a
    # language +[name,code]+ pair, e.g.,
    #
    #     [ 'lat', 'lat']
    #
    # Input +data+ will be, for example,
    #
    #     [
    #       ["Latin, with a few poems in Italian (f. 106r-108v).", "lat|ita"],
    #       ["Persian.", "per"],
    #       ["Spanish.", "spa"],
    #       ["Middle French.", "frm"],
    #       ["eng", "eng"],
    #       ["In Italian.", "ita"],
    #       ["Middle English.", "enm"],
    #       ["Middle English.", "eng|enm"]
    #     ]
    #
    # This method will add all the codes to this array, thus:
    #
    #     [
    #       ["Latin, with a few poems in Italian (f. 106r-108v).", "lat|ita"],
    #       ["Persian.", "per"],
    #       ["Spanish.", "spa"],
    #       ["Middle French.", "frm"],
    #       ["eng", "eng"],
    #       ["In Italian.", "ita"],
    #       ["Middle English.", "enm"],
    #       ["Middle English.", "eng|enm"],
    #       ['lat', 'lat'],
    #       ['ita', 'ita'],
    #       ['per', 'per'],
    #       ['spa', 'spa'],
    #       ['frm', 'frm'],
    #       ["eng", "eng"],
    #       ['enm', 'enm'],
    #       # etc.
    #     ]
    # @param [Array<Array<String>>] data an array of pairs language names and codes
    def self.expand_codes data
      data.uniq.map(&:last).flat_map { |codes|
        codes.split '|'
      }.sort.uniq.each do|code|
        data << [code,code]
      end
    end

    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          as_recorded = DS.clean_string record.xpath("datafield[@tag=546]/subfield[@code='a']").text
          codes = DS::MarcXML.extract_langs record
          as_recorded = codes if as_recorded.to_s =~ %r{^[|[:space:]]*$}
          data << [as_recorded, codes]
        end
      end
      expand_codes data
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        data << [DS::DS10.extract_language(xml), nil]
      end
      # the Mets files don't have codes; so no need for expand_codes
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        as_recorded = xml.xpath(xpath).text()
        codes = DS::OPennTEI.extract_language_codes xml
        as_recorded = codes if as_recorded.to_s.strip.empty?
        data << [as_recorded,codes]
      end
      expand_codes data
      add_recon_values data
      Recon.sort_and_dedupe data
    end
  end
end