# frozen_string_literal: true

module Recon
  module ReconType

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def set_name
        self::SET_NAME
      end

      def csv_headers
        self::CSV_HEADERS
      end

      def lookup_columns
        self::LOOKUP_COLUMNS
      end

      def key_columns
        self::KEY_COLUMNS
      end

      def as_recorded_column
        self::AS_RECORDED_COLUMN
      end

      def delimiter_map
        self::DELIMITER_MAP
      end

      def method_name
        self::METHOD_NAME
      end

      def balanced_columns
        self::BALANCED_COLUMNS
      end
    end
  end
end
