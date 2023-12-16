require 'nokogiri'

module Recon
  class Places

    extend DS::Util

    CSV_HEADERS = %w{ place_as_recorded authorized_label structured_value }

    def self.add_recon_values rows
      rows.each do |row|
        place_as_recorded = row.first
        labels            = Recon.lookup 'places', value: place_as_recorded, column: 'authorized_label'
        place_uris        = Recon.lookup 'places', value: place_as_recorded, column: 'structured_value'
        row << labels.to_s.gsub('|',';')
        row << place_uris.to_s.gsub('|',';')
      end
    end

    def self.lookup places, from_column: 'structured_value'
      places.map { |place|
        place_cleaned = DS::Util.clean_string place, terminator: ''
        place_uris = Recon.lookup 'places', value: place_cleaned, column: from_column
        place_uris.to_s.gsub '|', ';'
      }.join '|'
    end

    def self.from_marc files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data += DS::Extractor::MarcXML.extract_recon_places record
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data += DS::Extractor::DS10.extract_recon_places xml
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        data += DS::Extractor::OPennTEI.extract_recon_places xml
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

  end
end