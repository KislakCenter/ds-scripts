require 'nokogiri'
require_relative 'recon_type'

module Recon
  class Materials

    extend DS::Util
    include ReconType

    SET_NAME = :materials

    CSV_HEADERS = %i{
      material_as_recorded
      authorized_label
      structured_value
      ds_qid
    }

    LOOKUP_COLUMNS = %i{
      authorized_label
      structured_value
      ds_qid
    }

    KEY_COLUMNS = %i{
      material_as_recorded
    }

    METHOD_NAME = %i{ extract_materials }


    AS_RECORDED_COLUMN = :material_as_recorded

    DELIMITER_MAP = { '|' => ';' }

    def self.add_recon_values rows
      rows.each do |row|
        material_as_recorded = row.first
        material_labels      = Recon.lookup SET_NAME, value: material_as_recorded, column: 'authorized_label'
        material_uris        = Recon.lookup SET_NAME, value: material_as_recorded, column: 'structured_value'
        row << material_labels.to_s.gsub('|', ';')
        row << material_uris.to_s.gsub('|', ';')
      end
    end

    def self.lookup materials, column:
      materials.map { |material|
        material_uris = Recon.lookup SET_NAME, value: material, column: column
        material_uris.to_s.gsub '|', ';'
      }
    end

    def self.from_marc files
      data = []

      process_xml files, remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data += [DS::Extractor::MarcXml.collect_datafields(record, tags: 300, codes: 'b')]
          # require 'pry'; binding.pry
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      data = []
      process_xml files do |xml|
        data << [DS::Extractor::DsMetsXml.extract_material_as_recorded(xml)]
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_tei files
      data = []
      process_xml files, remove_namespaces: true do |xml|
        data += DS::Extractor::TeiXml.extract_material_as_recorded(xml).split('|')
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

  end
end
