require 'nokogiri'

module Recon
  class Places
    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          record.xpath("datafield[@tag=260]/subfield[@code='a']").each do |place|
            data << place.text
          end
        end
      end
      data.sort.uniq
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }

        DS::DS10.extract_production_place(xml).split('|').each do |place|
          data << place
        end

      end
      data.sort.uniq
    end

    def self.from_tei files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//origPlace/text()').each do |place|
          data << place.text
        end
      end
      data.sort.uniq
    end
  end
end