require 'net/http'
require 'nokogiri'

##
# Module with class methods for working with DS10 METS XML.
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
            DS.clean_string s, terminator: '.'
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
        DS.clean_string find_ms(xml).xpath(xpath).text
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
          DS.clean_string note, terminator: '.'
        }.join ' '
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
        # mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type='filename']
        xpath     = 'mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type="filename"]'
        filenames = page.xpath(xpath).map(&:text)
        return filenames unless filenames.empty?

        # no filename; find the ARK URL for the master image for this page
        extract_master_mets_file page
      end

      def extract_folio_num page
        # mets:mdWrap/mets:xmlData/mods:mods/mods:physicalDescription/mods:extent
        xpath = 'mets:mdWrap/mets:xmlData/mods:mods/mods:physicalDescription/mods:extent'
        page.xpath(xpath).map(&:text).join '; '
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
        # texts are three divs deep in the structMap
        # We need to get the IDs in order
        xpath = '/mets:mets/mets:structMap/mets:div/mets:div/mets:div/@DMDID'
        ids = xml.xpath(xpath).map &:text
        ids.map { |id|
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
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
          xml.xpath "/mets:mets/mets:dmdSec[@ID='#{id}']"
        }
      end

      protected

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