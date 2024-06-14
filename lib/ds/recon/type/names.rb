require 'nokogiri'

module Recon
  module Type
    class Names

      extend DS::Util
      include ReconType

      SET_NAME = :names

      RECON_CSV_HEADERS = %i{
      name_as_recorded
      role
      name_agr
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
        names.map { |name|
          Recon.lookup_single(SET_NAME, value: name, column: column)
        }
      end

    end

    class Authors < Names
      METHOD_NAME = %i{ extract_authors }.freeze
    end

    class Artists < Names
      METHOD_NAME = %i{ extract_artists }.freeze
    end

    class AssociatedAgents < Names
      METHOD_NAME = %i{ extract_associated_agents }.freeze
    end

    class FormerOwners < Names
      METHOD_NAME = %i{ extract_former_owners }.freeze
    end

    class Scribes < Names
      METHOD_NAME = %i{ extract_scribes }.freeze
    end
  end
end
