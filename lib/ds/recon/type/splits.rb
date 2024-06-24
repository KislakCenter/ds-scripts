# frozen_string_literal: true

module Recon
  module Type
    class Splits

      extend DS::Util
      include ReconType

      SET_NAME = :splits

      RECON_CSV_HEADERS = %i{ as_recorded authorized_label }

      LOOKUP_COLUMNS = %i{ authorized_label }

      KEY_COLUMNS = %i{ as_recorded }

      AS_RECORDED_COLUMN = :as_recorded

      DELIMITER_MAP = {}

      METHOD_NAME = []

      BALANCED_COLUMNS = {}


      def self._lookup_single as_recorded, from_column:
        key_values = [as_recorded]
        Recon.lookup_single(:splits, key_values: key_values , column: from_column)
      end

    end
  end
end
