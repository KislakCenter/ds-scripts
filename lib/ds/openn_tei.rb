module DS
  module OPennTEI
    module ClassMethods
      ##
      # From the given set of nodes, extract the names from all the respStmts with
      # resp text == type.
      #
      # @param [Nokogiri::XML:NodeSet] nodes the nodes to search for +respStmt+s
      # @param [Array<String>] types a list of types; e.g., +artist+, <tt>former
      #         owner</tt>
      # @return [String] pipe-separated list of names
      def extract_resp_names nodes: , types: []
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
          data << [author.xpath('text()').text, 'author', '', author['ref']]
        end

        _types = [ 'artist', 'scribe', 'former owner']
        type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
        xpath = %Q{//respStmt[#{type_query}]}
        nodes.xpath(xpath).each { |rs|
          data << [
            rs.xpath('persName/text()').text,
            rs.xpath('resp/text()').text,
            '',
            rs.xpath('persName/@ref/text()').text
          ]
        }
        data
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
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [String]
      def extract_physical_description xml
        parts = []
        parts << extract_support(xml)
        parts << extract_extent(xml)
        parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/foliation/text()')
        parts << extract_collation(xml)
        parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/layoutDesc/layout/text()')
        parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/scriptDesc/scriptNote/text()')
        parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()')
        parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()')
        parts.flatten.map { |x| x.to_s.strip }.reject(&:empty?).join '. '
      end

      def extract_production_date xml, range_sep: '-'
        date_array = xml.xpath('//origDate').map { |orig|
          orig.xpath('@notBefore|@notAfter').map { |d| d.text.to_i }.sort.join range_sep
        }.reject(&:empty?).join '|'
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

      ##
      # @param [Nokogiri::XML::Node] xml the TEI xml
      # @return [Array<String>]
      def extract_note xml
        # skip_pattern = %r{^(Support|Extent|Collation):\s*}i
        xpath = '/TEI/teiHeader/fileDesc/notesStmt/note[not(@type)]/text()'
        terminal_punct = %r{[.,;:?!]"?$}
        xml.xpath(xpath).map(&:text).map(&:strip).map { |note|
          note.gsub(%r{\s+}, ' ')
        }.map { |note|
          DS.terminate note, terminator: '.', force: false
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