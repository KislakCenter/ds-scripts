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

      def subset_column
        self::SUBSET_COLUMN
      end

      # Returns the balanced columns for the current object.
      #
      # Balanced columns should have equal numbers of fields and
      # subfields in each row; e.g., if fields are delimited by '|'
      # and subfields by ';', then the following are balanced:
      #
      # structured_value,authorized_label
      # a|b;c,d|e;f
      # 1|2|3,x|y|z
      # r,s
      #
      # @return [Array<Symbol>] The balanced columns.
      #
      # @example
      #   Recon::Materials.balanced_columns #=> [:structured_value, :authorized_label]
      def balanced_columns
        self::BALANCED_COLUMNS
      end
    end
  end
end
