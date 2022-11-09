require 'nokogiri'

module DS
  module Util
    ##
    # Open and parse each XML file in +files+, optionally stripping namespaces
    # from the parsed XML, running block on each XML document:
    #
    #   data = []
    #   process_xml files, remove_namespaces: true do |xml|
    #     data << xml.xpath('//some/path/text()').text
    #   end
    #
    # @yield [xml, data] yields a Nokogiri XML document and the array of data
    #         to populate the CSV; you must know the format of each item
    #         in the ++data++ array
    #
    # @param files [Enumerable<String>] XML files to process
    # @param remove_namespaces [Boolean] whether strip namespaces from parsed XML
    # @yieldparam xml [Nokogiri::XML::Document] the parsed document
    def process_xml files, remove_namespaces: false, &block
      files.each do |in_xml|
        # may be reading file list from STDIN; remove any trailing \r or \n
        xml = File.open(in_xml.chomp) { |f| Nokogiri::XML f }
        xml.remove_namespaces! if remove_namespaces
        yield xml
      end
    end
  end
end