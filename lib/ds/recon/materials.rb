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

    SUBSET_COLUMN = nil

    AS_RECORDED_COLUMN = :material_as_recorded

    DELIMITER_MAP = { '|' => ';' }

    BALANCED_COLUMNS = { materials: %w{ structured_value authorized_label } }

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

  end
end
