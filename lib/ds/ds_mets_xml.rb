require 'net/http'
require 'nokogiri'
require 'csv'

##
# Module with class methods for working with DS10 METS XML.
module DS
  module DsMetsXml
    module ClassMethods

      NS = {
        mods: 'http://www.loc.gov/mods/v3',
        mets: 'http://www.loc.gov/METS/',
      }

      def extract_institution_name xml
        extract_mets_creator(xml).first
      end

      def extract_mets_creator xml
        creator = xml.xpath('/mets:mets/mets:metsHdr/mets:agent[@ROLE="CREATOR" and @TYPE="ORGANIZATION"]/mets:name', NS).text
        creator.split %r{;;}
      end

      ##
      # Extract  and format all the physical description values  for the
      # manuscript and each part.
      #
      # # MS Note Phys desc
      #
      # - presentation -> Binding
      #
      # # MS Part phys description
      #
      #   - support -- accounted for as support
      #
      #   - marks - 'Watermarks'
      #   - medium -> 'Music'
      #   - physical description -> 'Other decoration'
      #   - physical details -> 'Figurative details'
      #   - script -> 'Script'
      #   - technique -> 'Layout'
      #
      # @param [Nokogiri::XML::Node] xml the document's xml
      # @return [Array] the physical description values
      def extract_physical_description xml
        physdesc = []
        physdesc += extract_ms_phys_desc xml
        physdesc += extract_part_phys_desc xml
        physdesc.flatten!

        clean_notes physdesc
      end

      def physdesc_note node, note_type, tag: nil
        if note_type == :none
          xpath = %q{mods:mods/mods:physicalDescription/mods:note[not(@type)]}
        else
          xpath = %Q{mods:mods/mods:physicalDescription/mods:note[@type = '#{note_type}']}
        end

        node.xpath(xpath).map { |x|
          tag.nil? ? x.text : "#{tag}: #{x.text}"
        }
      end

      def extract_ms_phys_desc xml
        ms = find_ms xml
        physdesc_note ms, 'presentation', tag: 'Binding'
      end

      def extract_pd_note part
        extent = extract_extent part

        xpath = %q{mods:mods/mods:physicalDescription/mods:note[@type = 'physical description']/text()}
        part.xpath(xpath).flat_map { |node|
          text = node.text
          notes = []
          if text =~ %r{;;}
            other_deco, num_scribes = text.split %r{;;+}
            notes << "Other decoration, #{extent}: #{other_deco}" unless other_deco.blank?
            notes << "Number of scribes, #{extent}: #{num_scribes}" unless num_scribes.blank?
          else
            notes << "Other decoration, #{extent}: #{text}" unless text.empty?
          end
          notes
        }
      end

      def extract_part_phys_desc xml
        parts = find_parts xml
        parts.flat_map { |part|
          extent = extract_extent part
          notes = []

          tag = "Figurative details, #{extent}"
          notes += physdesc_note part, 'physical details', tag: tag
          notes += extract_pd_note part
          tag = "Script, #{extent}"
          notes += physdesc_note part, 'script', tag: tag
          tag = "Music, #{extent}"
          notes += physdesc_note part, 'medium', tag: tag
          tag = "Layout, #{extent}"
          notes += physdesc_note part, 'technique', tag: tag
          tag = "Watermarks, #{extent}"
          notes += physdesc_note part, 'marks', tag: tag
          notes
        }
      end

      ##
      # DS 1.0 METS note types:
      #
      # # MS Note types:
      #
      #   Accounted for
      #   - ownership -- accounted for, former owner
      #   - action -- skip; administrative note: "Inputter ...."
      #   - admin -- acknowledgements
      #   - untyped -- 'Manuscript Note'
      #   - bibliography -- 'Bibliography'
      #   - source note -- skip; not present on DS legacy pages
      #
      #
      # # MS Note Phys desc
      #
      # - presentation -> Binding
      #
      # # Part note types:
      #
      #   - date - already accounted for
      #   - content - skip
      #   - admin - Acknowledgments
      #
      #   - untyped
      #
      # # MS Part phys description
      #
      #   - support -- accounted for as support
      #
      #   - marks - 'Watermarks'
      #   - medium -> 'Music'
      #   - physical description -> 'Other decoration'
      #   - physical details -> 'Figurative details'
      #   - script -> 'Script'
      #   - technique -> 'Layout'
      #
      #  # Text note types
      #
      #   Accounted for
      #   - admin - acknowledgements
      #
      #   - condition -> 'Status of text'
      #   - content -> handled as Text Incipit
      #   - untyped -> 'Text note'
      #
      #  # Page note types
      #
      #   Accounted for
      #     None
      #
      #   - content -> Folio Incipit
      #   - date -- skip
      #   - untyped -> 'Folio note'
      #
      def note_by_type node, note_type, tag: nil
        if note_type == :none
          xpath = %q{mods:mods/mods:note[not(@type)]/text()}
        else
          xpath = %Q{mods:mods/mods:note[@type = '#{note_type}']/text()}
        end

        node.xpath(xpath).map { |x|
          tag.nil? ? x.text : "#{tag}: #{x.text}"
        }
      end

      def extract_extent node
        xpath = 'mods:mods/mods:physicalDescription/mods:extent'
        node.xpath(xpath).flat_map { |extent|
          extent.text.split(%r{;;}).first
        }.join ', '
      end

      def extract_support xml
        find_parts(xml).flat_map { |part|
          note_by_type part, 'support'
        }.map { |s| s.downcase.chomp('.').strip }.uniq.join '|'
      end

      def extract_ownership xml, lookup_split: true
        xpath = "./descendant::mods:note[@type='ownership']/text()"
        notes = clean_notes(xml.xpath(xpath).flat_map(&:text))
        # unless notes.grep(/François-Nicolas/).empty?; require 'pry'; binding.pry; end
        return notes if notes.all? { |n| n.to_s.size < 400 }

        notes = if lookup_split
                  notes.flat_map { |n|
                    if n.to_s.size < 400
                      n
                    else
                      Recon::Splits._lookup_single(n, from_column: 'authorized_label').split('|')
                    end
                  }
                end


        clean_notes(notes).map { |n| DS.mark_long n }
      end

      def extract_author xml
        DS::DsMetsXml.extract_name xml, *%w{ author [author] }
      end

      def extract_artist xml
        DS::DsMetsXml.extract_name xml, *%w{ artist [artist] illuminator }
      end

      def extract_scribe xml
        DS::DsMetsXml.extract_name xml, *%w{ scribe [scribe] }
      end

      def extract_other_name xml
        DS::DsMetsXml.extract_name(xml, 'other').flat_map { |n| n.split %r{\s*;\s*} }
      end

      ##
      # Return a list of unique languages from the text-level <mods:note>s
      # that start with "lang:" (case -insensitive), joined with separator;
      # so, "Latin", rather than "Latin|Latin|Latin", etc.
      #
      # @return [String]
      def extract_language xml, separator: '|'
        # /mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:note
        # Can be Lang: or lang: or ???, so down case the text with translate()
        xpath = './descendant::mods:note[starts-with(translate(text(), "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"), "lang:")]'
        find_texts(xml).flat_map { |text|
          text.xpath(xpath).map{ |note| note.text.sub(%r{^lang:\s*}i, '') }
        }.uniq.join separator
      end

      def extract_name node, *roles
        # Roles have different cases: Author, author, etc.
        # Xpath 1.0 has no lower-case function, so use translate()
        translate = "translate(./mods:role/mods:roleTerm/text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"
        props = roles.map { |r| "#{translate} = '#{r}'"}.join ' or '
        xpath = "./descendant::mods:name[#{props}]"
        node.xpath(xpath).flat_map { |name |
          name.xpath('mods:namePart').text.split ';'
        }.map(&:strip).uniq
      end

      def extract_title xml
        xpath = 'mods:mods/mods:titleInfo/mods:title'
        find_texts(xml).flat_map { |text|
          text.xpath(xpath).map(&:text)
        }.reject { |t| t == '[Title not supplied]' }.join '|'
      end

      def extract_production_place xml
        parts = find_parts xml
        xpath = 'mods:mods/mods:originInfo/mods:place/mods:placeTerm'
        parts.map { |node|
          node.xpath(xpath).map { |place|
            place.text.split(%r{;;}).join ', '
          }
        }.uniq.join '|'
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
      # @param [Nokogiri::XML:Node] record a +<METS_XML>+ node
      # @return [Array<Array>] an array of arrays of values
      def extract_recon_places xml
        parts = find_parts xml
        xpath = 'mods:mods/mods:originInfo/mods:place/mods:placeTerm'
        parts.map { |node|
          node.xpath(xpath).map { |place|
            place.text.split(%r{;;}).reject(&:empty?).join ', '
          }
        }.uniq.reject &:empty? # some parts have no placeTerm
      end

      def extract_recon_titles xml
        data = []
        extract_title(xml).split('|').each do |title|
          data << [title, '', '', '']
        end
        data
      end

      def extract_recon_names xml
        data = []
        %w{author artist scribe [scribe] [author] illuminator other}.each do |role|
          extract_name(xml, role).each do |name|
            data << [name, role, '', '']
          end
        end

        extract_other_name(xml).each do |name|
          data << [name, 'other', '', '']
        end

        extract_ownership(xml).each do |name|
          data << [name, 'former owner', '', '']
        end
        data
      end

      ##
      # Extract acknowledgements, notes, physical descriptions, and
      # former owners; return all strings that start with SPLIT:,
      # remove 'SPLIT: ' and return an array of arrays that can
      # be treated as rows by Recon::Splits
      def extract_recon_splits xml
        # require 'pry'; binding.pry
        data = []
        data += DS::DsMetsXml.extract_ownership xml, lookup_split: false
        data.flatten.select { |d| d.to_s.size >= 400 }.map { |d| [d.strip] }
      end

      ##
      # For the legacy DS METS, this value is the value of
      # +mods:identifier[@type="local"]+ is the shelf mark. If there are other
      # ID types, we can't distinguish them from shelfmarks.
      #
      # @param [Nokogiri::XML:Node] xml a +<METS_XML>+ node
      # @return [String] the shelfmark
      def extract_shelfmark xml
        ms = find_ms xml
        ms.xpath('mods:mods/mods:identifier[@type="local"]/text()').text
      end

      ##
      # See the note for [Recon::Subjects]: Each source subject extraction
      # method should return a two dimensional array:
      #
      #     [["Islamic law--Early works to 1800", ""],
      #       ["Malikites--Early works to 1800", ""],
      #       ["Islamic law", ""],
      #       ["Malikites", ""],
      #       ["Arabic language--Grammar--Early works to 1800", ""],
      #       ["Arabic language--Grammar", ""],
      #       ...
      #       ]
      #
      # The second value is for those cases where the source provides an
      # authority URI. The METS records don't give a URI so this method always
      # returns the empty string for the second value.
      #
      # @param [Nokogiri::XML:Node] xml a +<METS_XML>+ node
      # @return [Array<String,String>] a two-dimenional array of subject and URI
      def recon_subjects xml
        extract_subjects(xml).map { |s| [s, '', '', ''] }
      end

      ##
      # Extract subjects, the `mods:originInfo/mods:edition` values for each
      # text. For example,
      #
      #    <mods:originInfo>
      #      <mods:edition>Alexander, de Villa Dei.</mods:edition>
      #      <mods:edition>Illumination of books and manuscripts, Medieval.</mods:edition>
      #      <mods:edition>Latin language--Grammar.</mods:edition>
      #      <mods:edition>Latin poetry, Medieval and modern.</mods:edition>
      #      <mods:edition>Manuscripts, Medieval--Connecticut--New Haven.</mods:edition>
      #    </mods:originInfo>
      #
      # @param [Nokogiri::XML:Node] xml a +<METS_XML>+ node
      # @return [Array<String>] an of subjects
      def extract_subjects xml
        xpath = '//mods:originInfo/mods:edition'
        data = find_texts(xml).flat_map { |text|
          text.xpath(xpath).map &:text
        }
        data
      end

      def extract_link_to_inst_record xml
        ms = find_ms xml
        # xpath mods:mods/mods:relatedItem/mods:location/mods:url
        xpath = "mods:mods/mods:relatedItem/mods:location/mods:url"
        ms.xpath(xpath).map(&:text).join '|'
      end

      def dated_by_scribe? xml
        parts = find_parts xml
        # mods:mods/mods:note
        xpath = 'mods:mods/mods:note[@type="date"]'
        parts.any? { |part |
          part.xpath(xpath).text.upcase == 'Y'
        }
      end

      ##
      # Return as a single string all the date values for the manuscript. This
      # is a concatenation of the values returned by DS10.extract_date_created,
      # DS10.extract_assigned_date, DS10.extract_date_range.
      #
      # @param [Nokogiri::XML:Node] xml the parsed METS xml document
      # @return [String] the concatenated date values
      def extract_date_as_recorded xml
        find_parts(xml).map { |part|
          date_created = extract_date_created part
          assigned     = extract_assigned_date part
          range        = extract_date_range(part).join '-'
          [date_created, assigned, range].uniq.reject(&:empty?).join '; '
        }.reject { |date| date.to_s.strip.empty? }.join '|'
      end

      ##
      # Extract ranges from `mods:dateCreated` elements where a @point is
      # defined, thus:
      #
      #   <mods:dateCreated point="start" encoding="iso8601">1300</mods:dateCreated>
      #   <mods:dateCreated point="end" encoding="iso8601">1399</mods:dateCreated>
      #
      # @param [Nokogiri::XML:Node] part a part-level node
      # @return [Array<Integer>] the start and end dates as an array of integers
      def extract_date_range part
        xpath      = 'mods:mods/mods:originInfo/mods:dateCreated[@point="start"]'

        start_date = part.xpath(xpath).text
        xpath      = 'mods:mods/mods:originInfo/mods:dateCreated[@point="end"]'
        end_date   = part.xpath(xpath).text
        [start_date, end_date].reject(&:empty?).map(&:to_i)
      end

      ##
      # Return any date not found in the `otherDate` or in a dateCreated date
      # range (see #extract_date_range); thus:
      #
      #     <mods:dateCreated>1537</mods:dateCreated>
      #     <mods:dateCreated>1531</mods:dateCreated>
      #     <mods:dateCreated>14??, October 21</mods:dateCreated>
      #     <mods:dateCreated>1462, July 23</mods:dateCreated>
      #     <mods:dateCreated>1549, November</mods:dateCreated>
      #
      # These values commonly give the date for "dated" manuscripts
      #
      # @param [Nokogiri::XML:Node] part a part-level node
      # @return [Array<Integer>] the content of any dateCreated without '@point'
      #                          defined
      def extract_date_created part
        xpath = 'mods:mods/mods:originInfo/mods:dateCreated[not(@point)]'
        part.xpath(xpath).map(&:text).join ', '
      end

      ##
      # Return dates found in the `otherDate` element, reformatting them as
      # needed. These examples are taken from several METS files.
      #
      #     <mods:dateOther>[ca. 1410]</mods:dateOther>
      #     <mods:dateOther>[between 1100 and 1200]</mods:dateOther>
      #     <mods:dateOther>[between 1450 and 1460]</mods:dateOther>
      #     <mods:dateOther>[between 1450 and 1500]</mods:dateOther>
      #     <mods:dateOther>s. XV#^3/4#</mods:dateOther>
      #     <mods:dateOther>s. XV</mods:dateOther>
      #     <mods:dateOther>s. XVI#^4/4#</mods:dateOther>
      #     <mods:dateOther>s. XVIII#^2/4#</mods:dateOther>
      #     <mods:dateOther>s. XV#^in#</mods:dateOther>
      #
      # Most dateOther values have the format:
      #
      #     s. XVII#^2#
      #
      # The notation #^<VAL># encodes a portion of the string that was presented
      # as superscript on the Berkeley DS site. DS 2.0 doesn't use the
      # superscripts; thus, when it occurs, this portion of the string is
      # reformatted `(<VAL>)`:
      #
      #     s. XVII#^2#   =>    s. XVII(2)
      #     s. XV#^ex#    =>    s. XV(ex)
      #     s. XVI#^in#   =>    s. XVI(in)
      #     s. X#^med#    =>    s. X(med)
      #     s. XII#^med#  =>    s. XII(med)
      #
      # @param [Nokogiri::XML:Node] part a part-level node
      # @return [Array<Integer>] the date string reformatted as described above
      def extract_assigned_date part
        xpath = 'mods:mods/mods:originInfo/mods:dateOther'
        part.xpath(xpath).text.gsub %r{#\^?([\w/]+)(\^|#)}, '(\1)'
      end

      def transform_production_date xml
        find_parts(xml).map { |part|
          extract_date_range(part).join '^'
        }.reject(&:empty?).join '|'
      end

      def extract_acknowledgements xml
        notes = []
        notes += find_ms(xml).flat_map { |ms| note_by_type ms, 'admin' }

        notes += find_parts(xml).flat_map { |part|
          extent = extract_extent part
          note_by_type part, 'admin', tag: extent
        }

        notes += find_texts(xml).flat_map { |text|
          extent = extract_extent text
          note_by_type text, 'admin', tag: extent
        }

        notes += find_pages(xml).flat_map { |page|
          extent = extract_extent page
          note_by_type page, 'admin', tag: extent
        }

        clean_notes notes
      end

      ##
      # Extract the filename for page. This will be either:
      #
      #  * the values for +mods:identifier+ with +@type='filename'+; or
      #
      #  * the filenames pointed to by the linked +mets:fptr+ in the
      #       +mets:fileGrp+ with +@USE='image/master'+
      #
      #  * an array containing +['NO_FILE']+, if no files are associated with
      #       the page
      #
      # There will almost always be one file, but at least one manuscript has
      # page with two associated images. Thus, we return an array.
      #
      # @param [Nokogiri::XML::Node] page the +mets:dmdSec+ node for the page
      # @return [Array<String>] array of all the filenames for +page+
      def extract_filenames page
        # mods:mods/mods:identifier[@type='filename']
        xpath     = 'mods:mods/mods:identifier[@type="filename"]'
        filenames = page.xpath(xpath).map(&:text)
        return filenames unless filenames.empty?

        # no filename; find the ARK URL for the master image for this page
        extract_master_mets_file page
      end

      def extract_folio_num page
        # mods:mods/mods:physicalDescription/mods:extent
        xpath = 'mods:mods/mods:physicalDescription/mods:extent'
        page.xpath(xpath).map(&:text).join '|'
      end

      ##
      # In some  METS files each page has a list of mets:fptr elements, we need
      # to get the @FILEID for the master image, but we don't know which one is
      # for the master. Thus we get all the @FILEIDs.
      #
      #     <mets:structMap>
      #       <mets:div TYPE="text" LABEL="[No Title for Display]" ADMID="RMD1" DMDID="DM1">
      #         <mets:div TYPE="item" LABEL="[No Title for Display]" DMDID="DM2">
      #           <mets:div TYPE="item" LABEL="[No Title for Display]" DMDID="DM3">
      #             <mets:div TYPE="item" LABEL="Music extending into right margin, upper right column." DMDID="DM4">
      #               <mets:fptr FILEID="FID1"/>
      #               <mets:fptr FILEID="FID3"/>
      #               <mets:fptr FILEID="FID5"/>
      #               <mets:fptr FILEID="FID7"/>
      #               <mets:fptr FILEID="FID9"/>
      #             </mets:div>
      #             <!-- snip -->
      #           </mets:div>
      #         </mets:div>
      #       </mets:div>
      #     </mets:structMap>
      #
      # Using the FILEIDs, find the corresponding mets:file in the
      # mets:fileGrp with @USE='image/master'.
      #
      #     <mets:fileGrp USE="image/master">
      #       <mets:file ID="FID1" MIMETYPE="image/tiff" SEQ="1" CREATED="2010-11-08T10:26:20.3" ADMID="ADM1 ADM4" GROUPID="GID1">
      #         <mets:FLocat xlink:href="http://nma.berkeley.edu/ark:/28722/bk0008v1k7q" LOCTYPE="URL"/>
      #       </mets:file>
      #       <mets:file ID="FID2" MIMETYPE="image/tiff" SEQ="2" CREATED="2010-11-08T10:26:20.393" ADMID="ADM1 ADM5" GROUPID="GID2">
      #         <mets:FLocat xlink:href="http://nma.berkeley.edu/ark:/28722/bk0008v1k88" LOCTYPE="URL"/>
      #       </mets:file>
      #     </mets:fileGrp>
      #
      # We then follow the +xlink:href+ to get the filename from the 'location'
      # HTTP header.
      #
      # @param [Nokogiri::XML::Node] page the +mets:dmdSec+ node for the page
      # @return [Array<String>] array of all the filenames for +page+
      def extract_master_mets_file page
        dmdid = page['ID']
        # all the mets:fptr @FILEIDs for this page
        xpath    = %Q{//mets:structMap/descendant::mets:div[@DMDID='#{dmdid}']/mets:fptr/@FILEID}

        # create an OR query because we don't know which FILEID is for the
        # master mets:file:
        #     "@ID = 'FID1' or @ID = 'FID3' or @ID = 'FID5' ... etc."
        id_query = page.xpath(xpath).map(&:text).map { |id| "@ID='#{id}'" }.join ' or '
        return ['NO_FILE'] if id_query.strip.empty? # there is no associated mets:fptr

        # the @xlink:href is the Berkeley ARK address; e.g., http://nma.berkeley.edu/ark:/28722/bk0008v1k88
        xpath          = "//mets:fileGrp[@USE='image/master']/mets:file[#{id_query}]/mets:FLocat/@xlink:href"
        fptr_addresses = page.xpath(xpath).map &:text
        return ['NO_FILE'] if fptr_addresses.empty? # I don't know if this happens, but just in case...

        # for each ARK address, find the TIFF filename
        fptr_addresses.map { |address| locate_filename address }
      end

      def extract_ms_note xml
        notes = []
        ms = find_ms xml
        notes += note_by_type ms, :none, tag: 'Manuscript note'
        notes += note_by_type ms, 'bibliography', tag: 'Bibliography'
        notes
      end

      def extract_part_note xml
        find_parts(xml).flat_map { |part|
          extent = extract_extent part
          note_by_type part, :none, tag: extent
        }
      end

      def extract_explicit node, tag:
        node.xpath('mods:mods/mods:abstract/text()').map { |n|
          "#{tag}: #{n.text}"
        }
      end

      def extract_text_note xml
        find_texts(xml).flat_map { |text|
          extent = extract_extent text
          notes = []
          notes += note_by_type text, :none, tag: extent
          notes += note_by_type text, 'condition', tag: "Status of text, #{extent}"
          notes += note_by_type text, 'content', tag: "Incipit, #{extent}"
          notes += extract_explicit text, tag: "Explicit, #{extent}"
          notes
        }
      end

      def extract_page_note xml
        find_pages(xml).flat_map { |page|
          extent = extract_extent page
          notes = []
          notes += note_by_type page, :none, tag: extent
          notes += note_by_type page, 'content', tag: "Incipit, #{extent}"
          notes += extract_explicit page, tag: "Explicit, #{extent}"
          notes
        }
      end

      ##
      # Extract the notes at all level from the +xml+, and return
      # an array of strings
      #
      # @param [Nokogiri::XML::Node] xml the document's xml
      # @return [Array<String>] the note values
      def extract_note xml
        notes = []
        # get all notes that don't have @type
        xpath = %q{//mods:note[not(@type)]/text()}
        notes += extract_ms_note xml
        notes += extract_part_note xml
        notes += extract_text_note xml
        notes += extract_docket xml
        notes += extract_page_note xml

        clean_notes notes
      end

      ##
      # **If** the +mods:mods+ element has a
      # <tt><mods:titleInfo type="alternative"></tt> element **and** a
      # <tt><mods:abstract[not(@displayLabel)]></tt>, **then** the content of
      # the <tt><mods:abstract[not(@displayLabel)]></tt> is an incipit; XPath:
      #
      #
      #    //mods:mods[./mods:titleInfo[@type="alternative"] and ./mods:abstract[not(@displayLabel)]]
      #
      #    //mods:mods[./mods:titleInfo[@type="alternative"]]/mods:abstract[not(@displayLabel)]/text()
      #
      #
      # **If** the `mods:mods` element has a `mods:titleInfo type="alternative"` element **and** a `<mods:note type="content">`, **then** the content of the `<mods:note type="content">` is an explicit; XPath:
      #
      #     //mods:mods[./mods:titleInfo[@type="alternative"] and ./mods:note[@type="content"]]
      #
      #     //mods:mods[./mods:titleInfo[@type="alternative"]]/mods:note[@type="content"]/text()
      #
      def extract_incipit_explicit xml
        # ./descendant::mods:physicalDescription
        # mods:mods/mods:originInfo/mods:place/mods:placeTerm
        # find any mod:mods containing an incipit or explicit
        xpath = %q{//mods:mods[./mods:titleInfo[@type="alternative"] and
                (./mods:abstract[not(@displayLabel)] or
                ./mods:note[@type="content"])]}

        find_texts(xml).flat_map { |node|
        # return an array for formatted incipits and explicits for this manuscript
          extent = node.xpath('./descendant::mods:physicalDescription/mods:extent/text()', NS).text
          node.xpath('./descendant::mods:abstract[not(@displayLabel)]/text()').map { |inc|
            "Incipit, #{extent}: #{inc}"
          } + node.xpath('./descendant::mods:note[@type="content"]/text()').map { |exp|
            "Explicit, #{extent}: #{exp}"
          }
        }
      end

      ##
      # DS METS can have +mods:abstract+ elments with +@displayLabel="docket"+.
      # Extract these values and return as an array.
      #
      # @param [Nokogiri::XML::Node] xml the document xml
      # @return [Array<String>] the note values
      def extract_docket xml
        xpath = %q{//mods:abstract[@displayLabel = 'docket']/text()}
        xml.xpath(xpath, NS).map { |docket|
          "Docket: #{docket.text}"
        }
      end

      def find_ms xml
        # the manuscript is one div deep in the structMap
        # /mets:mets/mets:structMap/mets:div/@DMDID
        xpath = '/mets:mets/mets:structMap/mets:div/@DMDID'
        id = xml.xpath(xpath).first.text
        xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']/mets:mdWrap/mets:xmlData"
      end

      def find_parts xml
        # /mets:mets/mets:structMap/mets:div/mets:div/@DMDID
        # manuscripts parts are two divs deep in the structMap
        # We need to get the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        # We can't count on the order or the numbering of the mets:dmdSec
        # elements outside of the structMap. Thus, we have to return an
        # array with the parts mets:dmdSec in the correct order.
        ids.map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']/mets:mdWrap/mets:xmlData"
        }
      end

      def find_texts xml
        # /mets:mets/mets:structMap/mets:div/mets:div/mets:div/@DMDID
        # texts are three divs deep in the structMap
        # We need to get the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        ids.map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']/mets:mdWrap/mets:xmlData"
        }
      end

      ##
      # @param [Nokogiri::XML::Node] xml parsed XML of the METS document
      # @return [Arry<Nokogiri::XML::Node>] array of the page-level +mets:dmdSec+
      #     nodes
      def find_pages xml
        # /mets:mets/mets:structMap/mets:div/mets:div/mets:div/mets:div/@DMDID
        # the pages are four divs deep in the structMap
        # We need the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        # collect dmdSec's for all the page IDs
        ids.flat_map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']/mets:mdWrap/mets:xmlData"
        }
      end

      def source_modified
        "2021-10-01"
      end

      # def find_iiif_manifest xml
      #   holding_institution = extract_institution_name xml
      #   shelfmark = extract_shelfmark xml
      #   key = iiif_manifest_key holding_institution, shelfmark
      #   iiif_manifests[key]
      # end
      #
      # @@iiif_manifests = nil
      # def iiif_manifests
      #   return @@iiif_manifests if @@iiif_manifests
      #   recon_repo = File.join DS.root, 'data', Settings.recon.git_local_name
      #   csv_file = File.join recon_repo, Settings.recon.iiif_manifests
      #
      #   @@iiif_manifests = CSV.readlines(csv_file, headers: true).inject({}) { |h,row|
      #     key = iiif_manifest_key row['holding_institution'], row['shelfmark']
      #     h.merge(key => row['iiif_manifest_url'])
      #   }
      # end

      protected

      def iiif_manifest_key holder, shelfmark
        qid = DS::Institutions.find_qid holder
        raise DSError, "No QID found for #{holder}" if qid.blank?
        normalize_key qid, shelfmark
      end

      def normalize_key *strings
        strings.join.downcase.gsub(%r{\s+}, '')
      end

      def clean_notes notes
        notes.flat_map { |note|
          # get node text and clean whitespace
          note.to_s.strip.gsub(%r{\s+}, ' ')
        }.uniq.reject { |note|
          # skip notes with prefixes like 'lang: '
          note.to_s =~ %r{\blang:\s*}i
        }.map { |note|
          # add period to any note without terminal punctuation: .,;:? or !
          DS::Util.terminate(note, terminator: '.', force: true)
        }
      end

      @@ark_cache = nil

      ##
      # Rather than follow the ARK URLs to retrieve the locations, use a
      # cache that maps the arks to the TIFF filenames.
      #
      # Cache format:
      #
      #     http://nma.berkeley.edu/ark:/28722/bk00091894z|dummy_MoConA_0000068.tif
      #     http://nma.berkeley.edu/ark:/28722/bk00091895h|dummy_MoConA_0000069.tif
      #     http://nma.berkeley.edu/ark:/28722/bk000918b51|dummy_MoConA_0000070.tif
      #     http://nma.berkeley.edu/ark:/28722/bk000918b6k|dummy_MoConA_0000071.tif
      #
      # This method lazily initializes a hash that maps the URL to the file name.
      #
      # @param [String] address the ark URL; e.g.,
      #     +http://nma.berkeley.edu/ark:/28722/bk000919772+
      # @return [String] the filename associated with +address+ or +nil+
      def search_ark_cache address
        if @@ark_cache.nil?
          STDERR.puts "Creating ARK cache"
          path = File.expand_path '../data/berkeley-arks.txt', __FILE__
          @@ark_cache = File.readlines(path).inject({}) { |h,line|
            ark, filename = line.strip.split '|'
            h.update({ ark => filename})
          }
        end
        @@ark_cache[address]
      end

      ##
      # Extract filename by following DS ARK URL (e.g.,
      # +http://nma.berkeley.edu/ark:/28722/bk000855n2z+). We can't get
      # the image, but we can get the filename from the redirect location
      # header. As soon as we get a location that ends in +.tif+, we extract
      # the basename and return it.
      #
      # We limit the number of redirects to 4 to prevent infinite recursion
      # following redirects. We should always get the filename in the first
      # call.
      #
      # @param [String] address ARK address of an image file
      # @param [Integer] limit decrementing count of recursive calls; stops
      #     at +0+
      # @return [String] the basename of the first +.tif+ file encountered
      def locate_filename address, limit=4
        # Before hitting the web, try the ARK/URL to FILE cache
        return search_ark_cache address if search_ark_cache address

        STDERR.puts "WARNING -- recursion: location='#{address}', limit=#{limit}" if limit < 4
        return if limit == 0

        resp     = Net::HTTP.get_response URI address
        location = resp['location']
        return                             if location.nil?
        # recurse if location isn't a TIFF file
        return locate_filename location, limit-1 unless location =~ %r{\.tif$}

        File.basename URI(location).path
      end
    end

    self.extend ClassMethods
  end
end
