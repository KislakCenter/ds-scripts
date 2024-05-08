require 'csv'

module DS
  module Extractor
    module MarcXml
      module ClassMethods

        ############################################################
        # NAMES
        ############################################################

        ##
        # Extract names from record using tags and relators. Tags understood are +100+,
        # +700+, and +710+. The +relators+ are used to require datafields based on the
        # contents of a subfield code +e+ containing the specified value, like 'scribe':
        #
        #     contains(./subfield[@code ='e'], 'scribe')
        #
        # @see #build_name_query for details on query construction
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @param [Array<String>] tags the MARC field tag[s]
        # @param [Array<String>] relators for +700$e+, +710$e+, a value[s] like 'former owner'
        # @return [String] pipe-separated list of names
        def extract_names_as_recorded record, tags: [], relators: []
          xpath = build_name_query tags: tags, relators: relators
          return '' if xpath.empty? # don't process nonsensical requests
          record.xpath(xpath).map { |datafield| DS::Util.clean_string extract_name_portion datafield }
        end

        ##
        # Extract names from record using tags and relators. Authors are extracted
        # from datafields 100, 110, 111, 700, 701, and 711.
        #
        # All 1xx are extracted, no relator is assumed and all 1xx are assumed to
        # be authors.
        #
        # 700, 710, and 711 are extracted when subfield 7xx$e contains 'author'.
        #
        # @see #build_name_query for details on query construction
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @return [Array<String>] list of names
        def extract_authors_as_recorded record
          authors = []
          authors += extract_names_as_recorded record, tags: [100, 110, 111]
          authors += extract_names_as_recorded record, tags: [700, 710, 711], relators: %w{author}
          authors
        end

        def extract_authors_as_recorded_agr record
          authors = []
          authors += extract_names_as_recorded_agr record, tags: [100, 110, 111]
          authors += extract_names_as_recorded_agr record, tags: [700, 710, 711], relators: %w{author}
          authors
        end

        def extract_scribes record
          extract_names(
            record, tags: [700, 710, 711], relators: ['scribe']
          )
        end

        def extract_scribes_as_recorded record
          extract_scribes(record).map &:as_recorded
        end

        def extract_scribes_as_recorded_agr record
          extract_scribes(record).map &:vernacular
        end

        def extract_artists record
          extract_names(
            record, tags: [700, 710, 711],
            relators:     ['artist', 'illuminator']
          )
        end

        def extract_artists_as_recorded record
          extract_artists(record).map &:as_recorded
        end

        def extract_artists_as_recorded_agr record
          extract_artists(record).map &:vernacular
        end

        def extract_former_owners record
          extract_names(
            record, tags: [700, 710, 711], relators: ['former owner']
          )
        end

        def extract_former_owners_as_recorded record
          extract_former_owners(record).map &:as_recorded
        end

        def extract_former_owners_as_recorded_agr record
          extract_former_owners(record).map &:vernacular
        end

        def extract_scribes_as_recorded_agr record
          extract_scribes(record).map &:vernacular
        end

        def extract_artists record
          extract_names(
            record, tags: [700, 710, 711],
            relators:     ['artist', 'illuminator']
          )
        end

        def extract_authors record
          extract_names(record, tags: [100, 110, 111]) +
            extract_names(record, tags: [700, 710, 711], relators: %w{author})
        end

        ##
        # For the given record, extract the names as an array of arrays, including
        # the concatenated name string (subfields, a, b, c, d) and, if present,
        # the alternate graphical representation (AGR) and authority number (or
        # URI).
        #
        # Each returned sub array will have three values: name, name AGR, URI.
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @param [Array<String>] tags the MARC field tag[s]
        # @param [Array<String>] relators for +700$e+, +710$e+, a value[s] like 'former owner'
        # @return [Array<Array<String>>]
        def extract_recon_names record, tags: [], relators: []
          extract_names(record, tags: tags, relators: relators).map &:to_a
          # xpath = build_name_query tags: tags, relators: relators
          # return '' if xpath.empty? # don't process nonsensical requests
          #
          # record.xpath(xpath).map { |datafield|
          #   row = []
          #   row << extract_name_portion(datafield)
          #   role = extract_role(datafield, relators: relators)
          #   row << (role.strip.empty? ? 'author' : role)
          #   row << extract_pn_agr(datafield)
          #   row << extract_authority_number(datafield)
          #   row
          # }
        end

        def extract_names record, tags: [], relators: []
          xpath = build_name_query tags: tags, relators: relators
          return [] if xpath.empty? # don't process nonsensical requests

          record.xpath(xpath).map { |datafield|

            as_recorded = extract_name_portion datafield
            role        = extract_role datafield, relators: relators
            role        = 'author' if role.blank?
            vernacular  = extract_pn_agr datafield
            ref         = extract_authority_number datafield

            DS::Extractor::Name.new(
              as_recorded: as_recorded, role: role,
              vernacular:  vernacular, ref: ref
            )
          }
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
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @param [Array<String>] tags the MARC field code[s]
        # @param [Array<String>] relators for +700$e+, +710$e+, a value[s] like 'former owner'
        def extract_names_as_recorded_agr record, tags: [], relators: []
          xpath = build_name_query tags: tags, relators: relators
          return '' if xpath.empty? # don't process nonsensical requests

          record.xpath(xpath).map { |datafield|
            extract_pn_agr datafield
          }
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
        # @param [Array<String>] tags the MARC field code[s]
        # @param [Array<String>] relators for +700$e+, +710$e+, a value[s] like 'former owner'
        # @return [String] the data field query string
        def build_name_query tags: [], relators: []
          return '' if tags.empty? # don't process nonsensical requests
          # make sure the tags are all strings
          _tags        = [tags].flatten.map &:to_s
          tag_query    = _tags.map { |t| "@tag = #{t}" }.join " or "
          query_string = "(#{tag_query})"

          _relators = [relators].flatten.map { |r| r.to_s.strip.downcase == 'none' ? :none : r }
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
        # Extract the the PN from datafield, pulling subfields $a, $b, $c, $d.
        #
        # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node with the name
        # @return [String]
        def extract_name_portion datafield
          codes = %w{ a b c d }
          value = collect_subfields datafield, codes: codes
          DS::Util.clean_string value, terminator: ''
        end

        ###
        # Extract the role value, subfield +$e+, from the given datafield.
        #
        # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node with the name
        # @return [String]
        def extract_role datafield, relators:
          relators_list = *relators
          return '' if relators_list.empty? or relators_list.include? :none
          # if there's no $e, stop processing
          return '' if datafield.xpath('subfield[@code = "e"]/text()').text.empty?

          df_roles    = datafield.xpath('subfield[@code = "e"]/text()').map(&:text)
          rel_pattern = /(#{relators_list.join('|')})/
          role        = df_roles.find { |role| role =~ rel_pattern }
          DS::Util.clean_string role, terminator: ''
        end

        #########################################################################
        # Miscellaneous authority values
        #########################################################################

        ###
        # Extract the language codes from controlfield 008 and datafield 041$a.
        #
        # @param [Nokogiri::XML::Node] record the marc:record node
        # @return [String]
        def extract_langs record
          # Language is in 008 at characters 35-37 (0-based indexing)
          (langs ||= []) << record.xpath("substring(controlfield[@tag='008']/text(), 36, 3)")
          # 041 is present if there's more than one language
          langs += record.xpath("datafield[@tag=041]/subfield[@code='a']").map(&:text)
          # if there are 041 values, the lang from 008 is repeated; remove the duplicate
          langs.select(&:present?).uniq
        end

        ##
        # Extract the language as record; default to the 546$a field; otheriwse
        # return the code values from controlfield 008 and 041$a.
        #
        # @param [Nokogiri::XML::Node] record the marc:record node
        # @return [String]
        def extract_languages_as_recorded record
          extract_languages(record).map &:as_recorded
        end

        def extract_languages record
          xpath = "datafield[@tag=546]/subfield[@code='a']"
          langs = record.xpath(xpath).map { |val|
            DS::Util.clean_string val.text, terminator: ''
          }.select(&:present?).map { |as_recorded|
            DS::Extractor::Language.new as_recorded: as_recorded
          }
          return langs if langs.present?

          extract_langs(record).map { |as_recorded|
            DS::Extractor::Language.new as_recorded: as_recorded
          }
        end

        #########################################################################
        # Genres and subjects
        #########################################################################
        ##
        # Extract genre and form terms from MARC datafield 655 values, where the
        # 655$2 value can be specified; e.g., +rbprov+, +aat+, +lcgft+.
        #
        # Set +sub2+ to +:all+ to extract all 655 terms
        #
        # @param [Nokogiri::XML::Node] record the MARC record
        # @param [Boolean] uniq whether to return only unique terms; default: +true+
        # @return [Array<String>] array of genre terms
        def extract_genres_as_recorded record, uniq: true
          terms = extract_genres(record, sub_sep: '--', vocab: :all).map(&:as_recorded)

          uniq ? terms.uniq : terms
        end

        ##
        # Return an array of strings of formatted subjects (600, 610, 611, 630,
        # 647, 648, 650, and 651). Subjects values are separated by '--':
        #
        #     <datafield ind1="1" ind2="0" tag="600">
        #       <subfield code="a">Cicero, Marcus Tullius</subfield>
        #       <subfield code="x">Spurious and doubtful works.</subfield>
        #     </datafield>
        #
        #     # => "Cicero, Marcus Tullius--Spurious and doubtful works"
        #
        # Subfields with codes 'b', 'c', 'd', 'p', 'q', and 't' are appended to
        # the preceding subfield:
        #
        #    <datafield ind1=" " ind2="7" tag="647">
        #      <subfield code="a">Conspiracy of Catiline</subfield>
        #      <subfield code="c">(Rome :</subfield>
        #      <subfield code="d">65-62 B.C.)</subfield>
        #      <subfield code="2">fast</subfield>
        #      <subfield code="0">(OCoLC)fst01352536</subfield>
        #    </datafield>
        #
        #    # => "Conspiracy of Catiline (Rome : 65-62 B.C.)"
        #
        #  @param [Nokogiri::XML::Node] record the MARC record
        # @return [Array<DS::Extractor::Subject>] an array of formatted subjects strings
        def extract_subject_by_tags record, tags: []
          tag_list = *tags
          raise "No tags given for subject extraction: #{tags.inspect}" if tag_list.empty?
          sep       = '--'
          tag_query = tag_list.map { |tag| "@tag=#{tag}" }.join " or "
          record.xpath("datafield[#{tag_query}]").map { |datafield|
            values = Hash.new { |hash, k| hash[k] = [] }
            vocab  = datafield.xpath('./@ind2').text
            datafield.xpath("subfield").map { |subfield|
              subfield_text = DS::Util.clean_string subfield.text
              subfield_code = subfield.xpath('./@code').text
              # require 'pry'; binding.pry if subfield_text =~ /accounting/i
              case subfield_code
              when 'e', 'w'
                # don't include these formatted in subject
              when 'b', 'c', 'd', 'p', 'q', 't'
                # append these to the preceding value
                # we assume that there is a preceding value
                values[:terms][-1] += " #{subfield_text}"
                values[:codes][-1] += ";#{subfield_code}"
              when %r{\A[[:alpha:]]\z}
                # any other codes: a, g, v, x, y, z
                values[:terms] << subfield_text
                values[:codes] << subfield_code
              when '2'
                vocab = subfield.text
              when '0'
                values[:urls] << subfield_text
              end
            }
            terms = DS::Util.clean_string values[:terms].join(sep), terminator: ''
            urls  = DS::Util.clean_string values[:urls].join(sep), terminator: ''
            codes = DS::Util.clean_string values[:codes].join(sep), terminator: ''
            DS::Extractor::Subject.new(
              as_recorded:          terms,
              subfield_codes:       codes,
              source_authority_uri: urls,
              vocab:                vocab
            )
          }

        end

        def extract_named_subjects_as_recorded record
          extract_named_subjects(record).map &:as_recorded
        end

        def extract_named_subjects record
          extract_subject_by_tags record, tags: [600, 610, 611, 630, 647]
        end

        def extract_subjects_as_recorded record
          extract_subjects(record).map &:as_recorded
        end

        def extract_subjects record
          extract_subject_by_tags record, tags: [648, 650, 651]
        end

        def extract_all_subjects record
          extract_named_subjects(record) + extract_subjects(record)
        end

        def extract_all_subjects_as_recorded record
          extract_all_subjects(record).map &:as_recorded
        end

        ##
        # Extract genre terms for reconciliation CSV output.
        #
        # Returns a two-dimensional array, each row is a place; and each row has
        # three columns: term, vocabulary, and authority number.
        #
        # @param [Nokogiri::XML:Node] record a +<MARC_RECORD>+ node
        # @return [Array<Array>] an array of arrays of values
        def extract_recon_genres record, sub_sep: '--'
          extract_genres(record, sub_sep: sub_sep).map(&:to_a)
        end

        def extract_genres record, sub_sep: '--', vocab: :all
          xpath = %q{datafield[@tag = 655]}
          record.xpath(xpath).filter_map { |datafield|
            as_recorded          = collect_subfields datafield, codes: 'abcvzyx'.split(//), sub_sep: sub_sep
            as_recorded          = DS::Util.clean_string as_recorded, terminator: ''
            term_vocab           = extract_vocabulary datafield
            source_authority_uri = extract_authority_number datafield
            if [:all, term_vocab].include? vocab
              DS::Extractor::Genre.new(
                as_recorded:          as_recorded,
                vocab:                term_vocab,
                source_authority_uri: source_authority_uri
              )
            end
          }
        end

        def extract_genre_vocabulary record
          extract_genres(record).map(&:vocab)
        end

        def extract_recon_subjects record
          extract_all_subjects(record).map &:to_a
        end

        #########################################################################
        # Place of production
        #########################################################################

        ##
        # Look for a place as recorded. Look first at 264$a, then 260$a; return ''
        # when no value is found
        # @param [Nokogiri::XML::Node] record the MARC record
        # @return [Array<String>] the place name or []
        def extract_production_places_as_recorded record
          xpath = "datafield[@tag=260 or @tag=264]/subfield[@code='a']/text()"
          record.xpath(xpath).map { |pn|
            DS::Util.clean_string pn.text, terminator: '' unless pn.to_s.strip.empty?
          }
        end

        ##
        # Extract the places of production MARC +260$a+ for reconciliation CSV
        # output.
        #
        # Returns a two-dimensional array, each row is a place; and each row has
        # one column: place name; for example:
        #
        #     [["Austria"],
        #      ["Germany"],
        #      ["France (?)"]]
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @return [Array<Array>] an array of arrays of values
        def extract_recon_places record
          extract_places(record).map &:to_a
        end

        def extract_places record
          xpath = "datafield[@tag=260 or @tag=264]/subfield[@code='a']/text()"
          record.xpath(xpath).map { |pn|
            next if pn.to_s.blank?
            as_recorded = DS::Util.clean_string(pn.text, terminator: '')
            DS::Extractor::Place.new as_recorded: as_recorded
          }
        end

        #########################################################################
        # Date of production
        #########################################################################

        ###
        # Extract the encoded date from controlfield 008.
        #
        # Follows
        #
        # - https://www.loc.gov/marc/bibliographic/bd046.html
        # - https://www.loc.gov/marc/bibliographic/bd046.html
        #
        # Returns an array containing a pair of dates or a single date,
        # or an empty array.
        #
        # The following date types have appeared in MARC records
        # contributed to DS as of 2024-02-27 and are handled here:
        #
        # b - No dates given; B.C. date involved
        #   - 'b        '
        #   - date is taken from 046$b, and if present $d or $e
        #   - See: https://www.loc.gov/marc/bibliographic/bd046.html
        #
        #
        # e - Detailed date
        #   - 'e11200520', 'e139403 x', 'e164509 t', 'e167707 y',
        #     'e187505 s'
        #   - the first date part is returned a single year
        #
        # i - Inclusive dates of collection
        #   - 'i07500800', 'i08000830', 'i1000    '
        #   - the first and -- if present -- second date part are
        #     returned as two years
        #
        # k - Range of years of bulk of collection
        #   - 'k15121716'
        #   - the first and second date parts are returned as two years
        #
        # m - Multiple dates
        #   - 'm0618193u', 'm07390741', 'm10751200', 'm16uu1637',
        #     'm17uu1900'
        #   - the first and second date parts are returned as two years
        #   - see note below on replacement of u's
        #
        # n - Dates unknown
        #   - 'nuuuuuuuu'
        #   - no date returned
        #
        # p - Date of distribution/release/issue and
        #     production/recording session when different
        #   - 'p1400    '
        #   - the first and -- if present -- second date part are
        #     returned as two years
        #
        # q - Questionable date
        # q - 'q01000299', 'q0979    ', 'q09910992', 'q10001099',
        #     'q1300    ', 'q13uu14uu', 'q13uu1693', 'q14011425',
        #     'q1425uuuu', 'q1450    ', 'q1460    ', 'q14uu14uu',
        #     'quuuu1597'
        #   - the first and -- if present -- second date part are
        #     returned as two years
        #   - if the second date part is 'uuuu', the first date part is
        #     returned as year; ; ‘q1425uuuu’ => 1425
        #   - if the first date part is 'uuuu', the second date part is
        #     returned as year; ‘quuuu1597’ => 1597
        #   - for partial date parts with u's, see the note below
        #
        # r - Reprint/reissue date and original date
        #   - 'r11751199'
        #   - the first date part is returned a single year
        #
        # s - Single known date/probable date
        # s - 's1171    ', 's1171 xx ', 's1192 ua ', 's1250||||',
        #     's1286 iq ', 's1315 sy ', 's1366 is ', 's1436 gw ',
        #     's1450 it ', 's1470 ly ', 's1470 tu ', 's1470 uuu',
        #     's1497 enk', 's1595 sp ', 's19uu    '
        #   - the first date part is returned a single year
        #   - see note below on replacement of u's
        #
        # | - No attempt to code
        #   - '|12501300'
        #   - this appears to be miscoding
        #   - nevertheless, '|' coded records will follow the default
        #     rule: date part one is returned a single year
        #
        # The following cases, so far unrepresented in contributor data,
        # will follow the default rule: date part one will be returned
        # as a single year.
        #
        # c - Continuing resource currently published
        # d - Continuing resource ceased publication
        # t - Publication date and copyright date
        # u - Continuing resource status unknown
        #
        # Note on the replacement of u's in partial year dates
        #
        #  - Where u's appear in the first date they are replace by 0;
        #    thus, 'q13uu1693'  => '1300, 1693'
        #  - Where u's appear in the second date they are replace by 9;
        #    thus, 'q14uu14uu'  => '1400, 1499'
        #
        # @param [Nokogiri::XML::Node] record the +marc:record+ node
        # @return [Array]
        def extract_date_range record
          # 008 controlfield; e.g.,
          #
          #     "220518q14001500xx            000 0     d"
          ctrl_008 = record.at_xpath("controlfield[@tag='008']")
          return [] unless ctrl_008 # return if no 008
          # get positions 7-15: q14001500
          date_str = ctrl_008.text[6, 9]
          code     = date_str[0] # 'm'
          part1    = extract_date_part date_str, 1, 4 # '0618'
          part1.gsub! /u/, '0' if part1.present?
          part2 = extract_date_part date_str, 5, 8 # '193u'
          part2.gsub! /u/, '9' if part2.present?

          compile_dates(record, code, part1, part2).filter_map { |y|
            y if y.present?
          }
        end

        def compile_dates record, code, part1, part2
          case code
          when 'i', 'k', 'm', 'p', 'q', '|'
            [part1, part2]
          when 'n'
            []
          when 'b'
            handle_bce_date record
          else
            [part1]
          end
          # return [part1, part2] if 'ikmpq|'.include? code
          # return [] if code = 'n'
          # return handle_bce_date record if code == 'b'
          # [part1]
        end

        def handle_bce_date record
          # "datafield[@tag=260]/subfield[@code='c' or @code='d']/text()")
          bce_date1 = record.at_xpath('datafield[@tag=046]/subfield[@code="b"]/text()').to_s
          # stop if there's no BCE date 1
          return [] if bce_date1.blank?

          xpath     = 'datafield[@tag=046]/subfield[@code="d"]/text()'
          bce_date2 = record.at_xpath(xpath).to_s

          return ["-#{bce_date1}", "-#{bce_date2}"] if bce_date2.present?

          xpath    = 'datafield[@tag=046]/subfield[@code="e"]/text()'
          ce_date2 = bce_date2 = record.at_xpath(xpath).to_s
          return ["-#{bce_date1}", ce_date2] if ce_date2.present?

          ["-#{bce_date1}"]
        end

        def extract_date_part datestring, ndx1, ndx2
          part = datestring[ndx1, ndx2]
          # part must start with a digit and match a seq of digits and/or u
          return unless part =~ /^\d[\du]+/

          part.sub! /^0+/, '' if part =~ /^0+[1-9]/
          part
        end

        ##
        # Look for a date as recorded. Look first at 260$c, then 260$d, then
        # 245$f, finally use the encoded date from 008
        def extract_production_date_as_recorded record
          # Note that MARC does not specify a subfield '260$d':
          #
          # https://www.loc.gov/marc/bibliographic/bd260.html
          #
          # However Cornell use $d to continue 260$c
          dar = record.xpath("datafield[@tag=260]/subfield[@code='c' or @code='d']/text()").map do |t|
            DS::Util.clean_string t.text.strip
          end.join ' '
          return [dar.strip] unless dar.strip.empty?

          dar = record.xpath("datafield[@tag=264]/subfield[@code='c']/text()").map do |t|
            DS::Util.clean_string t.text.strip
          end.join ' '
          return [dar.strip] unless dar.strip.empty?

          # 245 is the title field but can have a date in $f
          #
          # see: https://www.loc.gov/marc/bibliographic/bd245.html
          #
          # Cornell uses 245$f in records that also lack 260 or 264; see
          # '4600 Bd. Ms. 176':
          #
          # https://catalog.library.cornell.edu/catalog/6382455/librarian_view
          #
          #   <datafield ind1="0" ind2="0" tag="245">
          #     <subfield code="a">Shah-nameh,</subfield>
          #     <subfield code="f">1600s.</subfield>
          #   </datafield>
          #
          dar = record.xpath("datafield[@tag=245]/subfield[@code='f']").text
          return [DS::Util.clean_string(dar)] unless dar.strip.empty?

          encoded_date = extract_date_range record
          [encoded_date.join('_').strip]
        end

        #########################################################################
        # Titles
        #########################################################################

        def extract_recon_titles record
          extract_titles(record).to_a
        end

        def extract_titles record
          tar      = title_as_recorded record
          tar_agr  = DS::Util.clean_string DS::Extractor::MarcXml.title_as_recorded_agr(record, 245), terminator: ''
          utar     = DS::Util.clean_string DS::Extractor::MarcXml.uniform_titles_as_recorded(record), terminator: ''
          utar_agr = DS::Util.clean_string DS::Extractor::MarcXml.uniform_title_as_recorded_agr(record), terminator: ''

          [DS::Extractor::Title.new(
            as_recorded:              tar,
            vernacular:               tar_agr,
            uniform_title:            utar,
            uniform_title_vernacular: utar_agr
          )]
        end

        def extract_titles_as_recorded_agr record
          extract_titles(record).map &:vernacular
        end

        def title_as_recorded record
          xpath = "datafield[@tag=245]/subfield[@code='a' or @code='b']"
          record.xpath(xpath).map { |title|
            DS::Util.clean_string(title.text, terminator: '')
          }.join '; '
        end

        def title_as_recorded_agr record, tag
          linkage = record.xpath("datafield[@tag=#{tag}]/subfield[@code='6']").text
          return '' if linkage.empty?
          index = linkage.split('-').last
          xpath = "datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]/subfield[@code='a']"
          DS::Util.clean_string record.xpath(xpath).text.delete '[]'
        end

        def extract_titles_as_recorded record
          extract_titles(record).map &:as_recorded
        end

        def uniform_titles_as_recorded record
          title_240 = record.xpath("datafield[@tag=240]/subfield[@code='a']").text
          title_130 = record.xpath("datafield[@tag=130]/subfield[@code='a']").text
          [title_240, title_130].reject(&:empty?).map { |title|
            DS::Util.clean_string title, terminator: ''
          }.join '|'
        end

        def extract_uniform_titles_as_recorded record
          extract_titles(record).map &:uniform_title
        end

        def extract_uniform_titles_as_recorded_agr record
          extract_titles(record).map &:uniform_title_vernacular
        end

        def uniform_title_as_recorded_agr record
          tag240 = title_as_recorded_agr record, 240
          tag130 = title_as_recorded_agr record, 130
          [tag240, tag130].reject(&:empty?).map { |title|
            DS::Util.clean_string title
          }.join '|'
        end

        #########################################################################
        # Physical description
        #########################################################################
        def extract_physical_description record
          extract_extent(record)
        end

        def extract_material_as_recorded record
          extract_materials(record).map(&:as_recorded).first
        end

        def extract_materials record
          DS::Extractor::MarcXml.collect_datafields(
            record, tags: 300, codes: 'b'
          ).map { |material|
            DS::Extractor::Material.new as_recorded: material
          }
        end

        def extract_extent record
          subfield_xpath = "subfield[@code = 'a' or @code = 'b' or @code = 'c']"
          record.xpath("datafield[@tag=300]").map { |datafield|
            datafield.xpath(subfield_xpath).filter_map { |s|
              s.text unless s.text.empty?
            }.join ' '
          }.filter_map { |ext|
            "Extent: #{DS::Util.clean_string ext}" unless ext.strip.empty?
          }
        end

        #########################################################################
        # Notes
        #########################################################################
        ##
        # Extract notes from +record+.
        #
        # Extract values from `500$a` fields that do not begin with AMREMM
        # tags for specific values like 'Binding:'. Specifically, this method
        # ignores fields beginning with:
        #
        #    Pagination|Foliation|Layout|Colophon|Collation|Script|Decoration|\
        #         Binding|Origin|Watermarks|Watermark|Signatures|Shelfmark
        #
        # @param [Nokogiri::XML:Node] record a +<MARC_RECORD>+ node
        # @return [Array<String>] an array of note strings
        def extract_notes record
          xpath = "datafield[@tag=500 or @tag=561]/subfield[@code='a']/text()"
          record.xpath(xpath).map { |note|
            DS::Util.clean_string note.text.strip.gsub(%r{\s+}, ' ')
          }
        end

        ###
        # Extract the authority number, subfield +$0+ from the given datafield.
        #
        # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node with the name
        # @return [String]
        def extract_authority_number datafield
          xpath = "./subfield[@code='0']"
          datafield.xpath(xpath).text
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
        # @param [Nokogiri::XML::Node] datafield the main data field @tag = '100', '700', etc.
        # @return [String] the text representation of the value
        def extract_pn_agr datafield
          linkage = datafield.xpath("subfield[@code='6']").text
          return '' if linkage.empty?
          tag   = datafield.xpath('./@tag').text
          index = linkage.split('-').last
          xpath = "./parent::record/datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]"
          extract_name_portion datafield.xpath(xpath)
        end

        def extract_cataloging_convention record
          record.xpath('datafield[@tag=040]/subfield[@code="e"]/text()').text
        end

        ##
        # Extract datafields values with authority numbers (URL) when present
        # for reconciliation CSV output.
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @param [Array<String>] tags the MARC datafield tag(s)
        # @param [Array<String>] codes the MARC subfield code(s)
        # @param [String] sub_sep separator for joining subfield values
        # @return [Array<Array>] an array of arrays of values
        def collect_recon_datafields record, tags: [], codes: [], sub_sep: ' '
          _tags     = [tags].flatten.map &:to_s
          tag_query = _tags.map { |t| "@tag = #{t}" }.join " or "
          record.xpath("datafield[#{tag_query}]").map { |datafield|
            value  = collect_subfields datafield, codes: codes, sub_sep: sub_sep
            value  = DS::Util.clean_string value, terminator: ''
            number = datafield.xpath('subfield[@tag="0"]').text
            [value, number]
          }
        end

        ##
        # Extract subfield values specified by +tags+
        #
        # @param [Nokogiri::XML:Node] record a +<marc:record>+ node
        # @param [Array<String>] tags the MARC datafield tag(s)
        # @param [Array<String>] codes the MARC subfield code(s)
        # @param [String] field_sep separator for joining multiple datafield values
        # @param [String] sub_sep separator for joining subfield values
        # @return [Array<Array>] an array of arrays of values
        def collect_datafields record, tags: [], codes: [], field_sep: '|', sub_sep: ' '
          _tags     = [tags].flatten.map &:to_s
          tag_query = _tags.map { |t| "@tag = #{t}" }.join " or "
          record.xpath("datafield[#{tag_query}]").map { |datafield|
            value = collect_subfields datafield, codes: codes, sub_sep: sub_sep
            DS::Util.clean_string value, terminator: ''
          }
        end

        ##
        # @param [Nokogiri::XML::Node] datafield the term datafield
        # @return [String]
        def extract_vocabulary datafield
          return 'lcsh' if datafield['ind2'] == '0'

          vocab = datafield.xpath("subfield[@code=2]").text
          vocab.chomp '.' if vocab.present?
        end

        def collect_subfields datafield, codes: [], sub_sep: ' '
          # ensure that +codes+ is an array of strings
          _codes = [codes].flatten.map &:to_s
          # ['a', 'b', 'd', 'c'] => @code = 'a' or @code = 'b' or @code = 'c' or @code = 'd'
          code_query = _codes.map { |code| "@code = '#{code}'" }.join ' or '
          xpath      = %Q{subfield[#{code_query}]}
          DS::Util.clean_string datafield.xpath(xpath).map(&:text).reject(&:empty?).join sub_sep
        end

        def extract_001_control_number record, holdings_file = nil
          ids = []
          # add the MMS ID
          ids << extract_mmsid(record)

          ids.reject(&:empty?).join '|'
        end

        def extract_mmsid record
          record.xpath("controlfield[@tag=001]").text
        end

        def extract_acknowledgments record
          []
        end

        ##
        # Return an array of 500$a values that begin with +name:+ (+name+
        # followed by a colon +:+). The name prefix is removed if +strip_name+
        # is +true+; it's +false+ by default.
        #
        # @param [Nokogiri::XML::Node] record the MARC XML record
        # @param [String] name the named prefix, like 'Binding', *without* trailing colon
        # @param [Boolean] strip_name whether to remove the name prefix from
        #                 returned comments; default is +false+
        # @return [Array<String>] the matching
        def extract_named_500 record, name:, strip_name: false
          return [] if name.to_s.strip.empty?

          # format the prefix; make sure there's not an extra ':'
          prefix = "#{name.strip.chomp ':'}:"
          xpath  = %Q{datafield[@tag=500]/subfield[@code='a' and starts-with(translate(text(), "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), '#{prefix.downcase}')]/text()}
          record.xpath(xpath).map { |d|
            note = d.text.strip
            strip_name ? note.sub(%r{^#{prefix}\s*}i, '') : note
          }
        end

        # parse encoded date field into human readable date range
        def parse_008 date_string, range_sep: '-'
          date_string.scan(/\d{4}/).map(&:to_i).join range_sep
        end
      end

      self.extend ClassMethods
    end
  end
end
