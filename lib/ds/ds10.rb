require 'net/http'

module DS
  module DS10
    module ClassMethods

      NS = {
        mods: 'http://www.loc.gov/mods/v3',
        mets: 'http://www.loc.gov/METS/',
      }

      def clean_string string, terminator: nil
        # handle superscripts, whitespace, duplicate '.', and ensure a
        # terminator is present if added
        normal = string.to_s.gsub(%r{#\^([^#]+)#}, '(\1)').gsub(%r{\s+}, ' ').strip.gsub(%r{\.\.+}, '.')
        terminator.nil? ? normal : "#{normal.sub(%r{[.;,!?]+$}, '').strip}."
      end

      def extract_institution_name xml
        extract_mets_creator(xml).first
      end

      def extract_mets_creator xml
        creator = xml.xpath('/mets:mets/mets:metsHdr/mets:agent[@ROLE="CREATOR" and @TYPE="ORGANIZATION"]/mets:name', NS).text
        creator.split %r{;;}
      end

      def extract_part_name xml, name_type
        find_parts(xml).map { |part|
          extract_name part, name_type
        }.join '|'
      end

      def extract_text_name xml, name_type
        find_texts(xml).flat_map { |text|
          extract_name text, name_type
        }.join '|'
      end

      def extract_physical_description xml
        find_parts(xml).flat_map { |part|
          node = part.xpath('./descendant::mods:physicalDescription')

          extent    = extract_extent(node).flat_map { |s| "Extent: #{s}." }.join ' '
          details   = note_by_type node, 'physical details'
          marks     = note_by_type node, 'marks', tag: 'Marks'
          technique = note_by_type node, 'technique', tag: 'Technique'
          script    = note_by_type node, 'script', tag: 'Script'
          medium    = note_by_type node, 'medium', tag: 'Medium'
          support   = note_by_type node, 'support', tag: 'Support'
          desc      = note_by_type(node, 'physical description').flat_map { |d|
            d.split(%r{;;}).first
          }.join ' '
          [
            extent, details, marks, technique, script, medium, support, desc
          ].flatten.reject(&:empty?).map{ |s|
            clean_string s, terminator: '.'
          }.join ' '
        }.join '|'
      end

      def note_by_type node, note_type, tag: nil
        xpath = "./descendant::mods:note[@type='#{note_type}']"
        node.xpath(xpath).map { |x|
          tag.nil? ? x.text : "#{tag}: #{x.text}"
        }
      end

      def extract_extent phys_desc_node
        xpath = 'mods:extent'
        phys_desc_node.xpath(xpath).map { |extent|
          extent.text.split(%r{;;}).reject(&:empty?).join '; '
        }
      end

      def extract_support xml
        find_parts(xml).flat_map { |part|
          note_by_type part, 'support'
        }.map { |s| s.downcase.chomp('.') }.uniq.join '|'
      end

      def extract_ownership xml
        xpath = "./descendant::mods:note[@type='ownership']"
        clean_string find_ms(xml).xpath(xpath).text
      end

      def extract_language xml
        # /mets:mets/mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:note
        xpath = './descendant::mods:note[starts-with(text(), "lang:")]'
        find_texts(xml).flat_map { |text|
          text.xpath(xpath).map{ |note| note.text.sub(%r{^lang:\s*}, '') }
        }.join '|'
      end

      def extract_name node, name_type
        xpath = "./descendant::mods:name[./mods:role/mods:roleTerm/text() = '#{name_type}']"
        node.xpath(xpath).map { |name |
          name.xpath('mods:namePart').map(&:text).join ' '
        }
      end

      def extract_title xml
        xpath = "mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title"
        find_texts(xml).flat_map { |text|
          text.xpath('mets:mdWrap/mets:xmlData/mods:mods/mods:titleInfo/mods:title').map(&:text)
        }.reject { |t| t == '[Title not supplied]' }.join '|'
      end

      def extract_production_place xml
        parts = find_parts xml
        xpath = 'mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:place/mods:placeTerm'
        parts.map { |node|
          node.xpath(xpath).map { |place|
            place.text.split(%r{;;}).join ', '
          }
        }.uniq.join '|'
      end

      def extract_institution_id xml
        ms = find_ms xml
        ms.xpath('mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="local"]/text()')
      end

      def extract_link_to_inst_record xml
        ms = find_ms xml
        # xpath mets:mdWrap/mets:xmlData/mods:mods/mods:relatedItem/mods:location/mods:url
        xpath = "mets:mdWrap/mets:xmlData/mods:mods/mods:relatedItem/mods:location/mods:url"
        ms.xpath(xpath).map(&:text).join '|'
      end

      def dated_by_scribe? xml
        parts = find_parts xml
        # mets:mdWrap/mets:xmlData/mods:mods/mods:note
        xpath = 'mets:mdWrap/mets:xmlData/mods:mods/mods:note[@type="date"]'
        parts.any? { |part |
          part.xpath(xpath).text.upcase == 'Y'
        }
      end

      def extract_date_as_recorded xml
        find_parts(xml).map { |part |
          assigned = extract_assigned_date part
          range    = extract_date_range part
          [assigned, range].join ', '
        }.join '|'
      end

      def extract_date_range part
        xpath      = 'mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:dateCreated[@point="start"]'

        start_date = part.xpath(xpath).text
        xpath      = 'mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:dateCreated[@point="end"]'
        end_date   = part.xpath(xpath).text
        [start_date, end_date].join '-'
      end

      def extract_assigned_date part
        # Assigned values use a system of encoded superscripts; e.g.,
        #
        #     s. XVII#^2#
        #     s. XV#^ex#
        #     s. XVI#^in#
        #     s. X#^med#
        #     s. XII#^med#
        #
        # For now we replace the #^<VAL># with (<VAL>)
        xpath = 'mets:mdWrap/mets:xmlData/mods:mods/mods:originInfo/mods:dateOther'
        part.xpath(xpath).text.gsub %r{#\^(\w+)#}, '(\1)'
      end

      def extract_acknowledgements xml
        note_by_type(find_ms(xml), 'admin').map { |note|
          clean_string note, terminator: '.'
        }.join ' '
      end

      def extract_filenames page
        # mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type='filename']
        xpath     = 'mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="filename"]'
        filenames = page.xpath(xpath).map(&:text)
        return filenames unless filenames.empty?

        # no filename; find the fptr
        xpath    = %Q{//mets:structMap/descendant::mets:div[@DMDID='DM4']/mets:fptr/@FILEID}
        id_query = page.xpath(xpath).map(&:text).map { |id| "@ID='#{id}'" }.join ' or '
        return [] if id_query.strip.empty? # there is no associated mets:fptr

        xpath          = "//mets:fileGrp[@USE='image/master']/mets:file[#{id_query}]/mets:FLocat/@xlink:href"
        fptr_addresses = page.xpath(xpath).map &:text
        return [] if fptr_addresses.empty?

        fptr_addresses.map { |address| locate_filename address }
      end

      def find_parts xml
        # /mets:mets/mets:structMap/mets:div/mets:div/@DMDID
        # the parts are two divs deep in the structMap
        # We need to get the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        # We can't count on the order or the numbering of the mets:dmdSec
        # elements outside of the structMap. Thus, we have to return an
        # array with the parts mets:dmdSec in the correct order.
        ids.map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
        }
      end

      def find_ms xml
        # the manuscript is one div deep in the structMap
        # /mets:mets/mets:structMap/mets:div/@DMDID
        xpath = '/mets:mets/mets:structMap/mets:div/@DMDID'
        id = xml.xpath(xpath).first.text
        xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
      end

      def find_texts xml
        # /mets:mets/mets:structMap/mets:div/mets:div/mets:div/@DMDID
        # the texts are three divs deep in the structMap
        # We need to get the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        ids.map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
        }
      end

      def find_pages xml
        # /mets:mets/mets:structMap/mets:div/mets:div/mets:div/mets:div/@DMDID
        # The pages are four divs deep in the structMap
        # We need the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        ids.flat_map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
        }
      end

      protected

      def locate_filename address, limit=4
        return if limit == 0

        resp     = Net::HTTP.get_response URI address
        location = resp['location']
        return                             if location.nil?
        locate_filename location, limit-=1 unless location =~ %r{\.tif$}

        File.basename URI(location).path
      end
    end

    self.extend ClassMethods
  end
end