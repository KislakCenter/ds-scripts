require 'nokogiri'
require_relative 'recon_type'

module Recon
  class Names

    extend DS::Util
    include ReconType

    SET_NAME = :names

    CSV_HEADERS = %i{
      name_as_recorded
      role name_agr
      source_authority_uri
      instance_of
      authorized_label
      structured_value
      ds_qid
    }

    LOOKUP_COLUMNS = %i{
      authorized_label
      structured_value
      instance_of
      ds_qid
    }

    KEY_COLUMNS = %i{
      name_as_recorded
    }

    AS_RECORDED_COLUMN = :name_as_recorded

    DELIMITER_MAP = {}

    METHOD_NAME = %i{ extract_authors extract_artists extract_scribes extract_former_owners }

    BALANCED_COLUMNS = %i{ structured_value authorized_label instance_of }

    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.lookup('names', value: name, column: 'instance_of')
        row << Recon.lookup('names', value: name, column: 'authorized_label')
        row << Recon.lookup('names', value: name, column: 'structured_value')
      end
    end

    def self.lookup names, column:
      names.map {|name|
        Recon.lookup(SET_NAME, value: name, column: column)
      }
    end

    def self.from_marc files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data += DS::Extractor::MarcXml.extract_recon_names record, tags: [100, 110, 111]
          data += DS::Extractor::MarcXml.extract_recon_names record, tags: [700, 710, 711, 790, 791], relators: ['artist', 'illuminator', 'scribe', 'former owner', 'author']
        end
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data += DS::Extractor::DsMetsXml.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a,b| a.first <=> b.first }.uniq
    end

    def self.from_tei files
      data = []
      process_xml files,remove_namespaces: true do |xml|
        data += DS::Extractor::TeiXml.extract_recon_names xml
      end
      add_recon_values data
      data.sort { |a, b| a.first <=> b.first }.uniq
    end
  end
end
