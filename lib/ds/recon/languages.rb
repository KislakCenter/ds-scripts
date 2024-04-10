module Recon
  class Languages

    extend DS::Util

    CSV_HEADERS = %w{
      language_as_recorded
      language_code
      authorized_label
      structured_value
    }

    def self.add_recon_values rows
      rows.each do |row|
        lang = row.first
        row << Recon.lookup('languages', value: lang, column: 'authorized_label')
        row << Recon.lookup('languages', value: lang, column: 'structured_value')
      end
    end

    def self.lookup languages, from_column: 'structured_value', separator: '|'
      languages.split(separator).map { |lang|
        # make sure each group of languages is separated by ';'
        Recon.lookup('languages', value: lang, column: from_column).gsub('|', ';')
      }.join separator
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
    def self.expand_codes data, separator: '|'
      data.uniq.map(&:last).flat_map { |codes|
        codes.split separator
      }.sort.uniq.each do|code|
        data << [code,code]
      end
    end

    def self.from_marc files, separator: '|'
      data = []
      process_xml files,remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          as_recorded = DS::Util.clean_string record.xpath("datafield[@tag=546]/subfield[@code='a']").text, terminator: ''
          codes       = DS::MarcXml.extract_langs record, separator: separator
          as_recorded = codes.gsub('|', ';') if as_recorded.to_s =~ %r{^[|;[:space:]]*$}
          data << [as_recorded, codes]
        end
      end
      expand_codes data, separator: separator
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files, separator: '|'
      data = []
      process_xml files do |xml|
        DS::DS10.extract_language(xml, separator: separator).split(separator).each do |lang|
          data << [DS::Util.terminate(lang, terminator: ''), nil]
        end
      end
      # the Mets files don't have codes; so no need for expand_codes
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files, separator: '|'
      data = []
      # xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
      process_xml files,remove_namespaces: true do |xml|
        as_recorded = DS::TeiXml.extract_language_as_recorded xml
        codes       = DS::TeiXml.extract_language_codes xml, separator: separator
        data << [as_recorded,codes]
      end
      expand_codes data
      add_recon_values data
      Recon.sort_and_dedupe data
    end
  end
end
