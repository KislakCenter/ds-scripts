require 'nokogiri'

module Recon
  class Names

    extend DS::Util

    CSV_HEADERS = %w{
      name_as_recorded
      role name_agr
      source_authority_uri
      instance_of
      authorized_label
      structured_value
    }

    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.lookup('names', value: name, column: 'instance_of')
        row << Recon.lookup('names', value: name, column: 'authorized_label')
        row << Recon.lookup('names', value: name, column: 'structured_value')
      end
    end

    def self.lookup names, column:
      names.map do|name|
        Recon.lookup 'names', value: name, column: column
      end
    end

    def self.from_marc files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data += DS::Extractor::MarcXML.extract_recon_names record, tags: [100, 110, 111]
          data += DS::Extractor::MarcXML.extract_recon_names record, tags: [700, 710, 711, 790, 791], relators: ['artist', 'illuminator', 'scribe', 'former owner', 'author']
        end
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data += DS::Extractor::DS10.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        data += DS::Extractor::OPennTEI.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end