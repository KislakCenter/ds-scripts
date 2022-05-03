require 'nokogiri'

module Recon
  class Names
    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.extract_recon_names record, tags: [100, 110, 111]
          data += DS::MarcXML.extract_recon_names record, tags: [700, 710], relators: ['artist', 'illuminator', 'scribe', 'former owner']
        end
      end
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }

        data += DS::DS10.extract_recon_names xml
      end
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        nodes = xml.xpath('//msContents/msItem')
        data += DS::OPennTEI.extract_recon_names xml
      end
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end