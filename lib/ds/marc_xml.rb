module DS
  module MarcXML
    module ClassMethods

      ###
      # Extract the language codes from controlfield 008 and datafield 041$a.
      #
      # @param [Nokogiri::XML::Node] :record the marc:record node
      # @return [String]
      def extract_langs record
        (langs ||= []) << record.xpath("substring(controlfield[@tag='008']/text(), 36, 3)")
        langs += record.xpath("datafield[@tag=041]/subfield[@code='a']").map(&:text)
        langs.uniq.join '|'
      end

      ###
      # Extract the encoded date from controlfield 008.
      #
      # @param [Nokogiri::XML::Node] :record the +marc:record+ node
      # @return [String]
      def extract_encoded_date_008 record
        record.xpath "substring(controlfield[@tag='008']/text(), 7,9)"
      end

      ##
      # Extract names from record using tags and relators. Tags understood are +100+,
      # +700+, and +710+. The +relators+ are used to require datafields based on the
      # contents of a subfield code +e+ containing the specified value, like 'scribe':
      #
      #     contains(./subfield[@code ='e'], 'scribe')
      #
      # @see #build_name_query for details on query construction
      #
      # @param [Nokogiri::XML:Node] :record a +<marc:record>+ node
      # @param [Array<String>] :tags the MARC field code[s]
      # @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
      def extract_names_as_recorded record, tags: [], relators: []
        xpath = build_name_query tags: tags, relators: relators
        return '' if xpath.empty? # don't process nonsensical requests

        record.xpath(xpath).map { |datafield|
          extract_pn datafield
        }.join '|'
      end

      ##
      # Extract the alternate graphical representation of the name or return +''+.
      #
      # See MARC specification for 880 fields:
      #
      # * https://www.loc.gov/marc/bibliographic/bd880.html
      #
      # @see #build_name_query for details on query construction
      #
      # @param [Nokogiri::XML:Node] :record a +<marc:record>+ node
      # @param [Array<String>] :tags the MARC field code[s]
      # @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
      def extract_names_as_recorded_agr record, tags: [], relators: []
        xpath = build_name_query tags: tags, relators: relators
        return '' if xpath.empty? # don't process nonsensical requests

        record.xpath(xpath).map { |datafield|
          extract_pn_agr datafield
        }.join '|'
      end

      ##
      # Build names query tags and relators. Tags understood are +100+, +700+,
      # and +710+. The +relators+ are used to require datafields based on the contents
      # of a subfield code +e+ containing the specified value, like 'scribe':
      #
      #     contains(./subfield[@code ='e'], 'scribe')
      #
      # For relators see section <strong>$e - Relator term<strong>, here:
      #
      #   https://www.loc.gov/marc/bibliographic/bdx00.html
      #
      # To require the subfield not have a relator, pass +:none+ as the relator value.
      #
      #     build_name_query tags: ['100'], relators: :none
      #
      # This will add the following to the query.
      #
      #     not(./subfield[@code = 'e'])
      #
      # Note: In U. Penn manuscript catalog records, 700 and 710 fields that *do*
      # *not* have a subfield code +e+ are associated authors.
      #
      # @param [Array<String>] :tags the MARC field code[s]
      # @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
      # @return [String] the data field query string
      def build_name_query tags: [], relators: []
        return '' if tags.empty? # don't process nonsensical requests
        # make sure the tags are all strings
        _tags        = [tags].flatten.map &:to_s
        tag_query    = _tags.map { |t| "@tag = #{t}" }.join " or "
        query_string = "(#{tag_query})"

        _relators    = [relators].flatten.map { |r| r.to_s.strip.downcase == 'none' ? :none : r }
        return "datafield[#{query_string}]" if _relators.empty?

        if _relators.include? :none
          query_string += " and not(./subfield[@code = 'e'])"
          return "datafield[#{query_string}]"
        end

        relator_string = relators.map { |r| "contains(./subfield[@code ='e'], '#{r}')" }.join " or "
        query_string   += (relator_string.empty? ? '' : " and (#{relator_string})")
        "datafield[#{query_string}]"
      end

      ###
      # Extract the encoded date from controlfield 008.
      #
      # @param [Nokogiri::XML::Node] :datafield the +marc:datafield+ node with the name
      # @return [String]
      def extract_pn datafield
        codes = %w{ a b c d }
        collect_subfields datafield, codes: codes
      end

      ##
      # Extract the alternate graphical representation of the name or return +''+.
      #
      # See MARC specification for 880 fields:
      #
      # * https://www.loc.gov/marc/bibliographic/bd880.html
      #
      # Input will look like this:
      #
      #     <marc:datafield ind1="1" ind2=" " tag="100">
      #       <marc:subfield code="6">880-01</marc:subfield>
      #       <marc:subfield code="a">Urmawī, ʻAbd al-Muʼmin ibn Yūsuf,</marc:subfield>
      #       <marc:subfield code="d">approximately 1216-1294.</marc:subfield>
      #     </marc:datafield>
      #     <!-- ... -->
      #     <marc:datafield ind1="1" ind2=" " tag="880">
      #       <marc:subfield code="6">100-01//r</marc:subfield>
      #       <marc:subfield code="a">ارموي، عبد المؤمن بن يوسف،</marc:subfield>
      #       <marc:subfield code="d">اپرxمتلي 12161294.</marc:subfield>
      #     </marc:datafield>
      #
      # @param [Nokogiri::XML::Node] :datafield the main data field @tag = '100', '700', etc.
      # @return [String] the text representation of the value
      def extract_pn_agr datafield
        linkage = datafield.xpath("subfield[@code='6']").text
        return '' if linkage.empty?
        tag   = datafield.xpath('./@tag').text
        index = linkage.split('-').last
        xpath = "./parent::record/datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]"
        extract_pn datafield.xpath(xpath)
      end

      def collect_datafields record, tags: [], codes: [], field_sep:  '|', sub_sep: ' '
        _tags        = [tags].flatten.map &:to_s
        tag_query    = _tags.map { |t| "@tag = #{t}" }.join " or "
        # binding.pry
        record.xpath("datafield[#{tag_query}]").map { |datafield|
          collect_subfields datafield, codes: codes, sub_sep: sub_sep
        }.join field_sep
      end

      def collect_subfields datafield, codes: [], sub_sep: ' '
        # ensure that +codes+ is an array of strings
        _codes = [codes].flatten.map &:to_s
        # ['a', 'b', 'd', 'c'] => @code = 'a' or @code = 'b' or @code = 'c' or @code = 'd'
        code_query = _codes.map { |code| "@code = '#{code}'" }.join ' or '
        xpath      = %Q{subfield[#{code_query}]}
        datafield.xpath(xpath).map(&:text).reject(&:empty?).join sub_sep
      end

      def extract_title_agr record, tag
        linkage = record.xpath("datafield[@tag=#{tag}]/subfield[@code='6']").text
        return '' if linkage.empty?
        index = linkage.split('-').last
        xpath = "datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]/subfield[@code='a']"
        record.xpath(xpath).text
      end

      def extract_physical_description record
        parts = []
        extent = record.xpath("datafield[@tag=300]").map { |datafield|
          xpath = "subfield[@code = 'a' or @code = 'b' or @code = 'c']"
          datafield.xpath(xpath).map(&:text).reject(&:empty?).join ' '
        }.join ' '
        parts << "Extent: #{extent}" unless extent.strip.empty?
        parts << extract_named_500(record, name: 'Collation')
        parts << extract_named_500(record, name: 'Layout')
        parts << extract_named_500(record, name: 'Script')
        parts << extract_named_500(record, name: 'Decoration')
        parts << extract_named_500(record, name: 'Binding')
        parts.flatten.map(&:strip).join ' '
      end

      # We don't have a good way to look these up, so I'm hard-coding the addresses.
      # TODO: Make IIIF manifest mapping configurable or dynamic
      IIIF_MANIFESTS = {
        '9947675343503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3k649t48/manifest',
        '9947675343503681-test' => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3k649t48/manifest',
        '9950569233503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3zm0w/manifest',
        '9952666523503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p37w6764x/manifest',
        '9959647633503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3mp74/manifest',
        '9965025663503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3h00n/manifest',
        '9976106713503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3n29p909/manifest',
      }

      def find_iiif_manifest record
        mmsid = extract_mmsid record
        IIIF_MANIFESTS[mmsid.to_s]
      end

      def extract_holding_institution_ids record
        # start with the shelfmark
        ids = [find_shelfmark(record)]
        # add the MMS ID
        ids << extract_mmsid(record)

        ids.reject(&:empty?).join '|'
      end

      def find_shelfmark record
        callno = record.xpath('holdings/holding/call_number').text
        return callno unless callno.strip.empty?

        callno = record.xpath("datafield[@tag=99]/subfield[@code='a']").text
        return callno unless callno.strip.empty?

        # Princeton call number
        xpath = "datafield[@tag=852 and subfield[@code='b']/text() = 'hsvm']/subfield[@code='h']"
        callno = record.xpath(xpath).text
        return callno unless callno.strip.empty?

        xpath = "datafield[@tag='500']/subfield[@code='a' and starts-with(text(), 'Shelfmark:')]"
        callno = record.xpath(xpath).text
        return callno.sub(%r{^Shelfmark:\s*}, '') unless callno.strip.empty?

        # return empty string if we get this far
        ''
      end

      def extract_mmsid record
        record.xpath("controlfield[@tag=001]").text
      end

      def extract_named_500 record, name:
        return '' if name.to_s.strip.empty?

        xpath = "datafield[@tag=500]/subfield[@code='a' and starts-with(./text(), '#{name}')]"
        record.xpath(xpath).map { |d| d.text.sub(%r{^#{name}:?\s*}, '').strip }.join ' '
      end
    end

    self.extend ClassMethods
  end
end