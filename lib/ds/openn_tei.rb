module DS
  module OPennTEI

    RESP_FORMER_OWNER = 'former owner'
    RESP_SCRIBE = 'scribe'
    RESP_ARTIST = 'artist'
    module ClassMethods
      ##
      # From the given set of nodes, extract the names from all the respStmts with
      # resp text == type.
      #
      # @param [Nokogiri::XML:NodeSet] nodes the nodes to search for +respStmt+s
      # @param [Array<String>] types a list of types; e.g., +artist+, <tt>former
      #         owner</tt>
      # @return [String] pipe-separated list of names
      def extract_resp_nodes nodes: , types: []
        return '' if types.empty?
        _types = [types].flatten.map &:to_s
        type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
        xpath = %Q{//respStmt[#{type_query}]}
        nodes.xpath(xpath).map { |rs| rs.xpath('persName/text()') }.join '|'
      end

      ##
      # From the given set of nodes, extract the URIs from all the respStmts with
      # resp text == type.
      #
      # @param [Nokogiri::XML:NodeSet] nodes the nodes to search for +respStmt+s
      # @param [Array<String>] types a list of types; e.g., +artist+, <tt>former
      #         owner</tt>
      # @return [String] pipe-separated list of URIs
      def extract_resp_ids nodes: , types: []
        return '' if types.empty?
        _types = [types].flatten.map &:to_s
        type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
        xpath = %Q{//respStmt[#{type_query}]/persName}
        nodes.xpath(xpath).map { |rs| rs['ref'] }.reject(&:nil?).join '|'
      end

      def extract_recon_names xml
        data = []
        nodes = xml.xpath('//msContents/msItem')

        nodes.xpath('author').each do |author|
          if author.xpath('persName').text.empty?
            value = author.text.strip
            role = 'author'
            vernacular = nil
            ref = author['ref']
            data << [value, role, vernacular, ref]
          else
            data << build_recon_row(author, 'author')
          end
        end

        _types = [ 'artist', 'scribe', 'former owner']
        type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
        xpath = %Q{//respStmt[#{type_query}]}
        nodes.xpath(xpath).each do |rs|
          role = rs.xpath('resp/text()').text.strip
          data << build_recon_row(rs, role)
        end
        data
      end

      def build_recon_row resp_node, role
        value_xpath      = 'persName[not(@type) or @type="authority"]/text()'
        value            = resp_node.xpath(value_xpath).text.strip
        vernacular_xpath = 'persName[@type="vernacular"]/text()'
        vernacular       = resp_node.xpath(vernacular_xpath).text.strip
        ref              = resp_node['ref']

        [value, role, vernacular, ref]
      end

      ##
      # Extract language the ISO codes from +textLang+ attributes +@mainLang+ and
      # +@otherLangs+ and return as a pipe separated list.
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_language_codes xml, separator: '|'
        xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@mainLang | /TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@otherLangs'
        xml.xpath(xpath).flat_map { |lang| lang.value.split.reject(&:empty?) }.join separator
      end

      def extract_language_as_recorded xml, separator: '|'
        xpath       = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
        as_recorded = xml.xpath(xpath).text
        as_recorded = DS::OPennTEI.extract_language_codes xml, separator if as_recorded.to_s.strip.empty?
        as_recorded
      end

      def extract_title_as_recorded record
        record.xpath('//msItem[1]/title[not(@type)]/text()').map(&:text)
      end

      ##
      # Return an array of vernacular script titles equal in number to
      # the number of non-vernacular titles.
      #
      # This is a bit of a hack. Titles are list serially and Roman-
      # character and vernacular script titles are not paired. Thus:
      #
      #      <msItem>
      #        <title>Qaṭr al-nadā wa-ball al-ṣadā.</title>
      #        <title type="vernacular">قطر الندا وبل الصدا</title>
      #        <title>Second title</title>
      #        <author>
      #           <!-- ... -->
      #      </msItem>
      #
      # We assume that, when there is a vernacular title, it follows
      # its Roman equivalent. Each title without a type is assigned
      # a +nil+ value by default. The nil is replaced with the
      # vernacular title when present. The above sequence results in
      # the following:
      #
      #    [
      #       'قطر الندا وبل الصدا',
      #       nil
      #    ]
      #
      # @param [Nokogiri::XML::Node] record the TEI record
      # @return [Array<String>]
      def extract_title_as_recorded_agr record
        titles_agr = []
        record.xpath('//msItem[1]/title').each do |title|
          if title[:type] != 'vernacular'
            titles_agr << nil
          else
            titles_agr[-1] = title.text
          end
        end
        titles_agr
      end
      ##
      # Extract the collation formula and catchwords description from +supportDesc+,
      # returning those values that are present.
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_collation xml
        formula    = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/collation/p[not(catchwords)]/text()').text
        catchwords = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/collation/p/catchwords/text()').text
        s          = ''
        s          += "Collation: #{formula.strip}. " unless formula.strip.empty?
        s          += "#{catchwords.strip}"           unless catchwords.strip.empty?

        s.strip
      end

      ##
      # Extract the places of production for reconciliation CSV output.
      #
      # Returns a two-dimensional array, each row is a place; and each row has
      # one column: place name; for example:
      #
      #     [["Austria"],
      #      ["Germany"],
      #      ["France (?)"]]
      #
      # @param [Nokogiri::XML:Node] record a +<TEI>+ node
      # @return [Array<Array>] an array of arrays of values
      def extract_recon_places xml
        xml.xpath('//origPlace/text()').map { |place| [place.text] }
      end

      def extract_recon_titles xml
        xml.xpath('//msItem[1]/title/text()').map do |title|
          [title.text, '', '', '']
        end
      end

      ##
      # Extract +extent+ element and prefix with <tt>'Extent: '</tt>, return +''+
      # (empty string) if +extent+ is not present or empty.
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_extent xml
        formula = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()')
        return '' if formula.to_s.strip.empty?
        "Extent: #{formula}"
      end

      ##
      # Extract +support+ element text and prefix with <tt>'Support: '</tt>, return
      # +''+ (empty string) if +support+ is not present or empty.
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_support xml
        support = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p/text()')
        return '' if support.to_s.strip.empty?
        "Support: #{support}"
      end

      ##
      # Return the extent and support concatenated; e.g.,
      #
      #
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_physical_description xml
        extent = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text.strip
        extent = "Extent: #{extent}" unless extent.empty?
        support =  xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p/text()').text.strip.downcase

        [extent, support].reject(&:empty?).join('; ').capitalize
      end

      def extract_material_as_recorded record
        record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p').text
      end

      def extract_production_date xml, range_sep: '-'
        date_array = xml.xpath('//origDate').map { |orig|
          orig.xpath('@notBefore|@notAfter').map { |d| d.text.to_i }.sort.join range_sep
        }.reject(&:empty?).join '|'
      end

      def extract_production_place record
        record.xpath('//origPlace/text()').map(&:to_s).join '|'
      end

      def extract_recon_genres record
        xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="form/genre"]/term'
        record.xpath(xpath).map { |term|
          value  = term.text
          vocab  = 'openn-form/genre'
          number = term['target']
          [value, vocab, number]
        }
      end

      def extract_recon_subjects xml
        xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="subjects" or @n="keywords"]/term'
        xml.xpath(xpath).map do |term|
          value          = term.text
          subfield_codes = nil
          vocab          = "openn-#{term.parent['n']}"
          number         = term['target']
          [value, subfield_codes, vocab, number]
        end
      end

      def extract_genre_as_recorded xml
        xml.xpath('/TEI/teiHeader/profileDesc/textClass/keywords[@n="form/genre"]/term/text()').map &:text
      end

      def extract_subject_as_recorded xml
        xml.xpath('/TEI/teiHeader/profileDesc/textClass/keywords[@n="subjects" or @n="keywords"]/term/text()').map &:text
      end

      SIMPLE_NOTE_XPATH = '/TEI/teiHeader/fileDesc/notesStmt/note[not(@type)]/text()'
      BINDING_XPATH     = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()'
      LAYOUT_XPATH      = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/layoutDesc/layout/text()'
      SCRIPT_XPATH      = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/scriptDesc/scriptNote/text()'
      DECO_XPATH        = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()'
      RESOURCE_XPATH    = '/TEI/teiHeader/fileDesc/notesStmt/note[@type = "relatedResource"]/text()'
      PROVENANCE_XPATH  = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/provenance/text()'

      ##
      # Create an array of notes. Physical description notes, like
      # Binding, and Layout are mapped as prefixed notes as with MARC:
      #
      #   Binding: The binding note.
      #   Layout: The layout note.
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [Array<String>]
      def extract_note xml
        notes = []

        notes += build_notes xml, SIMPLE_NOTE_XPATH
        notes += build_notes xml, BINDING_XPATH, prefix: "Binding"
        notes += build_notes xml, LAYOUT_XPATH, prefix: "Layout"
        notes += build_notes xml, SCRIPT_XPATH, prefix: "Script"
        notes += build_notes xml, DECO_XPATH, prefix: "Decoration"
        notes += build_notes xml, RESOURCE_XPATH, prefix: "Related resource"
        notes += build_notes xml, PROVENANCE_XPATH, prefix: "Provenance"

        notes
      end

      WHITESPACE_RE = %r{\s+}
      # FLP Widener 5 has the following text with a pipe:
      #
      #   Delmira Espada, "A luz da grisalha. Arte, Liturgia e
      #     História no Livro de Horas dito de D. Leonor – Il165 da
      #     BNP," Medievalista [Online], 10 | 2011
      #
      # This breaks pipe-splitting and validation; for now, replace
      # pipes with ', ' (comma + space)
      MEDIAL_PIPE_RE = %r{\s*\|\s*} # match pipes

      ##
      # Clean the note text and optionally a prefix. The prefix is
      # prepended as:
      #
      #   "#{prefix}: Note text"
      #
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @param [String] xpath the xpath for the note(s)
      # @param [String] prefix value to prepend to the note; default: +nil+
      # @return [Array<String>]
      def build_notes xml, xpath, prefix: nil
        xml.xpath(xpath).map { |note|
          pref = prefix.to_s.strip.empty? ? '' : "#{prefix}: "
          cleaned = note.text
                        .gsub(WHITESPACE_RE, ' ')
                        .gsub(MEDIAL_PIPE_RE, ', ') # replace pipes with ', ' 🤷🏻
                        .strip
          "#{pref}#{cleaned}"
        }
      end

      ##
      # @param [Nokogiri::XML::Node] node
      # @return [Array<String>]
      def extract_author_name node
        # vern = vernacular script
        unless node.children.any? { |ch| ch['type'] == 'vernacular' }
          return node.text.strip
        end

        auth_node = node.children.find { |ch| ch['type'] == 'authority' }
        auth_node && auth_node.text.strip
      end

      def extract_authors xml
        names = []

        xml.xpath('//msItem/author').each { |node|
          next if node.text =~ /Free Library of Philadelphia/
          names << extract_author_name(node)
        }
        names
      end

      def extract_author_name_agr node
        agr_node = node.children.find { |ch| ch['type'] == 'vernacular' }
        agr_node && agr_node.text.strip
      end

      def extract_authors_agr xml
        names = []
        xml.xpath('//msItem/author').each { |node|
          next if node.text =~ /Free Library of Philadelphia/
          names << extract_author_name_agr(node)
        }
        names
      end

      def extract_resp_name node
        node.xpath('name|persName|orgName').find { |node|
          node['type'] != 'vernacular'
        }.text
      end

      def extract_resp_name_agr node
        agr_node = node.xpath('name|persName|orgName').find { |node|
          node['type'] == 'vernacular'
        }
        agr_node && agr_node.text
      end
      def extract_resp_nodes xml, resp
        xpath = "//respStmt[contains(translate(./resp/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '#{resp.to_s.strip.downcase}')]"
        xml.xpath(xpath)
      end

      def extract_former_owners xml
        extract_resp_nodes(xml, RESP_FORMER_OWNER).map { |node|
          extract_resp_name node
        }
      end

      def extract_former_owners_agr xml
        extract_resp_nodes(xml, RESP_FORMER_OWNER).map { |node|
          extract_resp_name_agr node
        }
      end

      def extract_holding_institution record
        record.xpath('(//msIdentifier/institution|//msIdentifier/repository)[1]').text
      end

      def extract_holding_institution_id_nummber record
        record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/altIdentifier[@type="bibid"]/idno').text
      end

      def extract_shelfmark record
        record.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]').text()
      end

      def extract_link_to_record record
        record.xpath('//altIdentifier[@type="resource"][1]/idno').text.strip
      end

      def extract_artists xml
        extract_resp_nodes(xml, RESP_ARTIST).map { |node|
          extract_resp_name node
        }
      end

      def extract_artists_agr xml
        extract_resp_nodes(xml, RESP_ARTIST).map { |node|
          extract_resp_name_agr node
        }
      end

      def extract_scribes xml
        extract_resp_nodes(xml, RESP_SCRIBE).map { |node|
          extract_resp_name node
        }
      end

      def extract_scribes_agr xml
        extract_resp_nodes(xml, RESP_SCRIBE).map { |node|
          extract_resp_name_agr node
        }
      end

      def source_modified xml
        record_date = xml.xpath('/TEI/teiHeader/fileDesc/publicationStmt/date/@when').text
        return nil if record_date.empty?
        record_date
      end
    end

    self.extend ClassMethods
  end
end