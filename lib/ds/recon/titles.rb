require 'nokogiri'

module Recon
  class Titles

    extend DS::Util

    CSV_HEADERS = %w{
      title_as_recorded
      title_as_recorded_agr
      uniform_title_as_recorded
      uniform_title_as_recorded_agr
      authorized_label
    }

    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.lookup('titles', value: name, column: 'authorized_label')
      end
    end

    def self.lookup names, column:
      names.map do|name|
        Recon.lookup 'titles', value: name, column: column
      end
    end

    def self.from_marc files
      data = []
      process_xml files, remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data << DS::MarcXML.extract_recon_titles(record)
        end
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data += DS::DS10.extract_recon_titles xml
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        data += DS::OPennTEI.extract_recon_titles xml
      end
      add_recon_values data
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end