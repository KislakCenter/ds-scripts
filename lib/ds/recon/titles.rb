require 'nokogiri'
require_relative 'recon_type'

module Recon
  class Titles

    extend DS::Util
    include ReconType

    SET_NAME = 'titles'

    CSV_HEADERS = %i{
      title_as_recorded
      title_as_recorded_agr
      uniform_title_as_recorded
      uniform_title_as_recorded_agr
      authorized_label
      ds_qid
    }

    LOOKUP_COLUMNS = %i{
      authorized_label
      ds_qid
    }

    KEY_COLUMNS = %i{
      title_as_recorded
    }
    # TODO: add uniform_title_as_recorded as KEY column


    AS_RECORDED_COLUMN = %i{
      title_as_recorded
    }

    DELIMITER_MAP = { '|' => ';' }

    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.lookup('titles', value: name, column: 'authorized_label')
      end
    end

    def self.lookup names, column:
      names.map { |name|
        Recon.lookup 'titles', value: name, column: column
      }
    end

    def self.from_marc files
      data = []
      process_xml files, remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data << DS::Extractor::MarcXml.extract_recon_titles(record)
        end
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data += DS::Extractor::DsMetsXml.extract_recon_titles xml
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        data += DS::Extractor::TeiXml.extract_recon_titles xml
      end
      add_recon_values data
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end
