module DS
  module DS10

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
    end

    self.extend ClassMethods
  end
end