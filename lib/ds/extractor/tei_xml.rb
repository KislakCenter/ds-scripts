module DS
  module Extractor
    module TeiXml

      RESP_FORMER_OWNER = 'former owner'
      RESP_SCRIBE       = 'scribe'
      RESP_ARTIST       = 'artist'
      MS_CREATOR_RESPS  = [
        RESP_FORMER_OWNER,
        RESP_SCRIBE,
        RESP_ARTIST
      ]

      RESP_CATALOGER       = 'cataloger'
      RESP_CONTRIBUTOR     = 'contributor'
      ACKNOWLEDGMENT_RESPS = [
        RESP_CATALOGER,
        RESP_CONTRIBUTOR,
      ]

      module ClassMethods

        ############################################################
        # NAMES
        ############################################################

        # Extracts authors from the given XML record.
        #
        # @param [Nokogiri::XML:Node] xml the XML record to extract authors from
        # @return [Array<DS::Extractor::Name>] list of extracted author names
        def extract_authors xml
          names = []
          xml.xpath('//msContents/msItem/author').map do |node|
            next if node.text =~ /Free Library of Philadelphia/

            name_node   = node.at_xpath('(name|persName)[not(@type = "vernacular")]')
            prenormal   = name_node ? name_node.text : node.text
            as_recorded = DS::Util.normalize_string prenormal

            ref        = node['ref']
            ref        = name_node['ref'] if name_node
            role       = 'author'
            vern_name  = node.at_xpath('(persName|name)[@type = "vernacular"]')
            vernacular = DS::Util.normalize_string(vern_name.text) if vern_name

            params = {
              as_recorded: as_recorded,
              ref:         ref,
              role:        role,
              vernacular:  vernacular
            }
            names << DS::Extractor::Name.new(**params)
          end
          names
        end

        # Extract authors as recorded from the given XML record.
        #
        # @param [Nokogiri::XML:Node] xml a TEI XML record
        # @return [Array<String>] list of authors as recorded
        def extract_authors_as_recorded xml
          extract_authors(xml).map(&:as_recorded)
        end

        # Extracts authors as recorded with vernacular form from the given XML record.
        #
        # @param [Nokogiri::XML:Node] xml a TEI XML record
        # @return [Array<String>] the extracted authors as recorded with vernacular form
        def extract_authors_as_recorded_agr xml
          extract_authors(xml).map(&:vernacular)
        end


        ##
        # All respStmts for the given +resp+ (e.g., 'artist') and return
        # the values as Name instances
        #
        # @param [Nokogiri::XML::NodeSet] xml the parsed TEI XML
        # @return [Array<Name>]
        def extract_resps xml, *resp_names
          # There are a variety of respStmt patterns; for example:
          #
          #    <respStmt>
          #      <resp>former owner</resp>
          #      <persName type="authority">Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
          #      <persName type="vernacular">يوسف بن شيخ محمد الجمالي.</persName>
          #    </respStmt>
          #
          #    <respStmt>
          #      <resp>former owner</resp>
          #      <persName type="authority">Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
          #    </respStmt>
          #
          #    <respStmt>
          #      <resp>former owner</resp>
          #      <persName>Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
          #    </respStmt>
          #
          #    <respStmt>
          #      <resp>former owner</resp>
          #      <name>Jamālī, Yūsuf ibn Shaykh Muḥammad</name>
          #    </respStmt>
          #
          #
          resp_query = resp_names.map { |t|
            %Q{contains(translate(./resp/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '#{t.to_s.strip.downcase}')}
          }.join ' or '

          xpath = "//respStmt[#{resp_query}]"
          xml.xpath(xpath).map { |node|

            auth_name   = node.at_xpath('(persName|name)[not(@type = "vernacular")]')
            as_recorded = DS::Util.normalize_string(auth_name.text) if auth_name
            ref         = auth_name['ref'] if auth_name
            vern_name   = node.at_xpath('(persName|name)[@type = "vernacular"]')
            vernacular  = DS::Util.normalize_string(vern_name.text) if vern_name
            resp        = node.at_xpath('resp/text()').to_s

            params = {
              as_recorded: as_recorded,
              ref:         ref,
              role:        resp.downcase.strip,
              vernacular:  vernacular
            }
            DS::Extractor::Name.new **params
          }
        end

        ##
        # All names, authors, and names with resps: former owner, scribe,
        # artist with returned as two-dimensional array with each row
        # having these values:
        #
        #   * name as recorded
        #   * role (author, former owner, etc.)
        #   * name in vernacular script
        #   * ref (authority URL)
        #
        # All missing values are returned as +nil+:
        #
        #   [
        #     ["Horace", "author", nil, "https://viaf.org/viaf/100227522/"],
        #     ["Hodossy, Imre", "former owner", nil, nil],
        #     ["Jān Sipār Khān ibn Rustamdilkhān, -1701?", "former owner", "جان سپار خان بن رستمدلخان،", nil]
        #   ]
        #
        # @param [Nokogiri::XML::NodeSet] xml the parsed TEI XML
        # @return [Array<Name>]
        def extract_recon_names xml
          data = []

          data += extract_authors(xml).map(&:to_a)
          data += extract_resps(xml, *MS_CREATOR_RESPS).map(&:to_a)

          data
        end

        # Extracts artists as recorded from the given record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted artists as recorded
        def extract_artists_as_recorded xml
          extract_artists(xml).map(&:as_recorded)
        end

        # Extracts artists as recorded with vernacular form from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted artists as recorded with vernacular form
        def extract_artists_as_recorded_agr xml
          extract_artists(xml).map(&:vernacular)
        end

        # Extracts artists from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted artists
        def extract_artists xml
          extract_resps(xml, RESP_ARTIST)
        end

        # Extracts scribes as recorded from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted scribes as recorded
        def extract_scribes_as_recorded xml
          extract_scribes(xml).map &:as_recorded
        end

        # Extracts scribes as recorded with vernacular form from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted scribes as recorded with vernacular form
        def extract_scribes_as_recorded_agr xml
          extract_scribes(xml).map &:vernacular
        end

        # Extracts scribes from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted scribes
        def extract_scribes xml
          extract_resps(xml, RESP_SCRIBE)
        end

        # Extracts former owners as recorded from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted former owners as recorded
        def extract_former_owners_as_recorded xml
          extract_former_owners(xml).map &:as_recorded
        end

        # Extracts former owners as recorded with vernacular form from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted former owners as recorded with vernacular form
        def extract_former_owners_as_recorded_agr xml
          extract_former_owners(xml).map &:vernacular
        end

        # Extracts former owners from the given XML record.
        #
        # @param [Nokogiri::XML::Node] xml the parsed TEI XML
        # @return [Array<String>] the extracted former owners
        def extract_former_owners xml
          extract_resps(xml, RESP_FORMER_OWNER)
        end

        #########################################################################
        # Miscellaneous authority values
        #########################################################################

        # Extracts the material as recorded from the given TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [String] the extracted material as recorded
        def extract_material_as_recorded record
          # xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p'
          # extract_normalized_strings(record, xpath).first
          extract_materials(record).map(&:as_recorded).first
        end

        # Extracts materials from the given TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [Array<DS::Extractor::Material>] the extracted materials
        def extract_materials record
          xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p'
          extract_normalized_strings(record, xpath).map { |material|
            DS::Extractor::Material.new as_recorded: material
          }
        end

        # Extracts the languages as recorded from the given XML with an optional separator.
        #
        # @param [Nokogiri::XML::Node] xml the XML node containing language information
        # @param [String] separator the separator to use when multiple languages are extracted
        # @return [Array<String>] the extracted languages as recorded
        def extract_languages_as_recorded xml, separator: '|'
          extract_languages(xml).map &:as_recorded
        end

        ##
        # Extract language the ISO codes from +textLang+ attributes +@mainLang+ and
        # +@otherLangs+ and return as a pipe separated list.
        #
        # @param [Nokogiri::XML::Node] xml the TEI xml
        # @return [String]
        def extract_language_codes xml, separator: '|'
          extract_languages(xml).map &:codes
        end

        # Extracts the languages from the given TEI XML record using the specified xpath.
        # Each language is mapped to a Language object containing the language as recorded and its ISO codes.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [Array<DS::Extractor::Language>] list of Language objects
        def extract_languages record
          xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang'
          record.xpath(xpath).map { |text_lang|
            codes = Set.new
            codes << text_lang['mainLang']
            codes += text_lang['otherLang'].to_s.split
            if text_lang.text.present?
              as_recorded = text_lang.text
            else
              as_recorded = codes.join '|'
            end

            DS::Extractor::Language.new as_recorded: as_recorded, codes: codes
          }
        end

        #########################################################################
        # Genres and subjects
        #########################################################################

        # Extracts genre terms from the given TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [Array<Array>] an array of arrays containing value, vocabulary, and number for each term
        def extract_recon_genres record
          xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="form/genre"]/term'
          record.xpath(xpath).map { |term|
            value  = DS::Util.normalize_string term.text
            vocab  = 'openn-form/genre'
            number = term['target']
            [value, vocab, number]
          }
        end

        # Extracts subject terms from the given TEI XML record.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array] an array containing value, subfield codes, vocabulary, and number for each term
        def extract_recon_subjects xml
          xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="subjects" or @n="keywords"]/term'
          xml.xpath(xpath).map do |term|
            value          = DS::Util.normalize_string term.text
            subfield_codes = nil
            vocab          = "openn-#{term.parent['n']}"
            number         = term['target']
            [value, subfield_codes, vocab, number]
          end
        end

        # Extracts genres from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array<String>] the extracted genres
        def extract_genres_as_recorded xml
          extract_genres(xml).map &:as_recorded
        end

        # Extracts genres from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array<DS::Extractor::Genre>] the extracted genres
        def extract_genres xml
          xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="form/genre"]/term/text()'
          extract_normalized_strings(xml, xpath).map { |term|
            DS::Extractor::Genre.new as_recorded: term
          }
        end

        # Extracts subjects from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array<String>] the extracted subjects
        def extract_subjects_as_recorded xml
          extract_subjects(xml).map &:as_recorded
        end

        # Extracts all subjects from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array<String>] the extracted subjects
        def extract_all_subjects_as_recorded xml
          extract_subjects_as_recorded xml
        end

        # Extracts subjects from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @return [Array<DS::Extractor::Subject>] the extracted subjects
        def extract_subjects xml
          xpath = '/TEI/teiHeader/profileDesc/textClass/keywords[@n="subjects" or @n="keywords"]/term/text()'
          extract_normalized_strings(xml, xpath).map { |term|
            DS::Extractor::Subject.new as_recorded: term
          }
        end

        #########################################################################
        # Place of production
        #########################################################################

        # Extracts the places of production from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [Array<String>] the extracted places of production as recorded
        def extract_production_places_as_recorded record
          extract_places(record).map &:as_recorded
        end

        # Extracts places from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @return [Array<DS::Extractor::Place>] the extracted places
        def extract_places record
          xpath = '//origPlace'
          extract_normalized_strings(record, xpath).map { |place|
            DS::Extractor::Place.new as_recorded: place
          }
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
        # @param [Nokogiri::XML:Node] xml a +<TEI>+ node
        # @return [Array<Array>] an array of arrays of values
        def extract_recon_places xml
          xpath = '//origPlace/text()'
          extract_normalized_strings(xml, xpath).map { |place| [place] }
        end

        #########################################################################
        # Date of production
        #########################################################################

        # Extracts the date of production from the given TEI XML record as recorded.
        #
        # @param [Nokogiri::XML::Node] xml the TEI XML record
        # @param [String] range_sep the separator for the date range
        # @return [String] the extracted date of production as recorded
        def extract_production_date_as_recorded xml, range_sep: '-'
          extract_date_range(xml, range_sep: range_sep)
        end

        # Extracts and formats date ranges as recorded in the given TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI XML record
        # @param [String] range_sep the separator for the date range
        # @return [Array<String>] an array of formatted date ranges
        def extract_date_range record, range_sep: '-'
          record.xpath('//origDate').map { |orig|
            orig.xpath('@notBefore|@notAfter').map { |d| d.text.to_i }.sort.join range_sep
          }
        end

        #########################################################################
        # Titles
        #########################################################################

        ##
        # Return an array of Title instances equal in number to
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
        # its Roman equivalent. This script runs through all +<title>+
        # elements and creates a Title struct for each title where
        #
        #   @type != 'vernacular'
        #
        # When +@type+ is 'vernacular' is sets the +as_recorded_agr+
        # of the previous Title instance to that value.
        #
        # @param [Nokogiri::XML::Node] record the TEI record
        # @return [Array<Title>]
        def extract_titles record
          titles = []
          record.xpath('//msItem[1]/title').each do |title|
            if title[:type] != 'vernacular'
              titles << DS::Extractor::Title.new(
                as_recorded: DS::Util.normalize_string(title.text)
              )
            else
              titles.last.vernacular = DS::Util.normalize_string title.text
            end
          end
          titles
        end

        # Extracts the titles from the given TEI record as recorded.
        #
        # @param [Nokogiri::XML::Node] record the TEI record
        # @return [Array<String>] list of titles as recorded
        def extract_titles_as_recorded record
          extract_titles(record).map { |t| t.as_recorded }
        end

        # Extracts the titles from the given TEI record as recorded in the vernacular language.
        #
        # @param [Nokogiri::XML::Node] record the TEI record
        # @return [Array<String>] list of titles in the vernacular language as recorded
        def extract_titles_as_recorded_agr record
          extract_titles(record).map { |t| t.vernacular }
        end

        # Extracts the titles from the given TEI record to an array of titles.
        #
        # @param [Nokogiri::XML::Node] xml the TEI record
        # @return [Array<Array>] list of titles converted to arrays
        def extract_recon_titles xml
          extract_titles(xml).map { |t| t.to_a }
        end

        #########################################################################
        # Physical description
        #########################################################################
        ##
        # Return the extent and support concatenated; e.g.,
        #
        # @param [Nokogiri::XML::Node] xml the TEI xml
        # @return [String]
        def extract_physical_description xml
          xpath   = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()'
          extent  = extract_normalized_strings(xml, xpath).first
          extent  = "Extent: #{extent}" unless extent.blank?
          xpath   = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p/text()'
          support = extract_normalized_strings(xml, xpath).first

          desc = [extent, support].reject(&:blank?).join('; ').capitalize
          [desc]
        end

        #########################################################################
        # Notes
        #########################################################################
        SIMPLE_NOTE_XPATH = '/TEI/teiHeader/fileDesc/notesStmt/note[not(@type)]/text()'
        BINDING_XPATH     = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()'
        LAYOUT_XPATH      = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/layoutDesc/layout/text()'
        SCRIPT_XPATH      = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/scriptDesc/scriptNote/text()'
        DECO_XPATH        = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()'
        RESOURCE_XPATH    = '/TEI/teiHeader/fileDesc/notesStmt/note[@type = "relatedResource"]/text()'
        PROVENANCE_XPATH  = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/history/provenance/text()'

        ##
        # Create an array of notes. Physical description notes, like
        # Binding, and Layout are mapped as prefixed notes as with TEI:
        #
        #   Binding: The binding note.
        #   Layout: The layout note.
        #
        # @param [Nokogiri::XML::Node] xml the TEI xml
        # @return [Array<String>]
        def extract_notes xml
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

        WHITESPACE_RE  = %r{\s+}
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
          pref = prefix.blank? ? '' : "#{prefix}: "
          extract_normalized_strings(xml, xpath).map { |value|
            "#{pref}#{value}"
          }
        end

        #########################################################################
        # Holding information
        #########################################################################

        # Extracts the holding institution from the given record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [String] the extracted holding institution
        def extract_holding_institution record
          xpath = '(//msIdentifier/institution|//msIdentifier/repository)[1]'
          extract_normalized_strings(record, xpath).first
        end

        # Extracts the holding institution id number from the given record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [String] the extracted holding institution id number
        def extract_holding_institution_id_nummber record
          xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/altIdentifier[@type="bibid"]/idno'
          extract_normalized_strings(record, xpath).first
        end

        # Extracts the shelfmark from the given record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [String] the extracted shelfmark
        def extract_shelfmark record
          xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]'
          extract_normalized_strings(record, xpath).first
        end

        # Extracts the link to the record from the given record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [String] the extracted link to the record
        def extract_link_to_record record
          xpath = '//altIdentifier[@type="resource"][1]/idno'
          extract_normalized_strings(record, xpath).first
        end

        #########################################################################
        # Acknowledgments
        #########################################################################

        # Extracts the funder information from the TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [Array<String>] an array of funders extracted from the record
        def extract_funder record
          xpath = '/TEI/teiHeader/fileDesc/titleStmt/funder'
          extract_normalized_strings(record, xpath).map { |name| "Funder: #{name}" }
        end

        # Extracts acknowledgments from the TEI XML record.
        #
        # @param [Nokogiri::XML::Node] record the TEI xml representing a TEI XML record
        # @return [Array<String>] an array of acknowledgments extracted from the record
        def extract_acknowledgments record
          names = extract_resps(record, *ACKNOWLEDGMENT_RESPS).map { |name|
            "#{name.role.capitalize}: #{name.as_recorded}"
          }
          names + extract_funder(record)
        end

        #########################################################################
        # Utility methods
        #########################################################################

        # Extracts normalized strings from the given record based on the provided xpath.
        #
        # @param [Nokogiri::XML::Node] record the record to extract normalized strings from
        # @param [String] xpath the xpath to specify the location of the strings in the record
        # @return [Array<String>] an array of normalized strings extracted from the record
        def extract_normalized_strings record, xpath
          record.xpath(xpath).map { |node| DS::Util.normalize_string node.text }
        end
      end

      self.extend ClassMethods
    end
  end
end
