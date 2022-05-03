require 'nokogiri'

module Recon
  class Places
    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.extract_recon_places record
        end
      end
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        data += DS::DS10.extract_recon_places xml
      end
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        data += DS::OPennTEI.extract_recon_places xml
      end
      Recon.sort_and_dedupe data
    end
  end
end