require 'nokogiri'
require_relative 'recon_type'

module Recon
  class Titles

    extend DS::Util
    include ReconType

    SET_NAME = :titles

    METHOD_NAME = %i{ extract_titles }

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

    KEY_COLUMNS =  %i{ :title_as_recorded }

    SUBSET_COLUMN = nil

    AS_RECORDED_COLUMN = :title_as_recorded

    DELIMITER_MAP = { '|' => ';' }

    BALANCED_COLUMNS = {}

    def self.add_recon_values rows
      rows.each do |row|
        name = row.first
        row << Recon.lookup(SET_NAME, value: name, column: 'authorized_label')
      end
    end

    def self.lookup names, column:
      names.map { |name|
        Recon.lookup SET_NAME, value: name, column: column
      }
    end
  end
end
