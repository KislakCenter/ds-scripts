require 'nokogiri'

module Recon
  class Places
    def self.add_recon_values rows
      rows.each do |row|
        place_as_recorded = row.first
        place_uris = Recon.lookup 'places', value: place_as_recorded, column: 'structured_value'
        row << place_uris.to_s.gsub('|', ';')
      end
    end

    def self.lookup places
      places.map { |place|
        place_cleaned = DS.clean_string place, terminator: ''
        place_uris = Recon.lookup 'places', value: place_cleaned, column: 'structured_value'
        place_uris.to_s.gsub '|', ';'
      }.join '|'
    end

    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.extract_recon_places record
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        data += DS::DS10.extract_recon_places xml
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        data += DS::OPennTEI.extract_recon_places xml
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

  end
end