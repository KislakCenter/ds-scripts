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

    SUBSET_COLUMN = nil

    AS_RECORDED_COLUMN = :name_as_recorded

    DELIMITER_MAP = {}

    METHOD_NAME = %i{ extract_authors extract_artists extract_scribes extract_former_owners }

    BALANCED_COLUMNS = { names: %i{ structured_value authorized_label instance_of } }

    def self.lookup names, column:
      names.map {|name|
        Recon.lookup(SET_NAME, value: name, column: column)
      }
    end

  end
end
