# frozen_string_literal: true


module Recon
  module Type
    ##
    # The Recon::Type::ReconType module should be included in all
    # Recon::Type classes. It provides access to recon type
    # configuration information. Its methods support the lookup and
    # enrichment of DS::Extractor::BaseTerm object values.
    #
    # ReconType methods define recon CSV columns, the c, the columns
    # retrieved fom the DS data dictionaries, the lookup key columns,
    # the import CSV as recorded column (eg., author_as_recorded),
    # and, for validation purposes, the balanced columns; that is,
    # those columns in the recon CSVs that must have equal numbers of
    # subfields in each row.
    #
    # Classes that include Recon::Type::ReconType should define these
    # constants
    #
    #   SET_NAME :: the name of the recon set; e.g., :places
    #   RECON_CSV_HEADERS :: the recon CSV headers; e.g., [:place_as_recorded, :authorized_label, :structured_value, :ds_qid]
    #   LOOKUP_COLUMNS :: the  columns to extract from the data dictionaries; e.g., [:authorized_label, :structured_value, :ds_qid]
    #   KEY_COLUMNS :: the key columns in the recon CSV; e.g., [:place_as_recorded]
    #   AS_RECORDED_COLUMN :: the column in the recon CSV that holds the as-recorded value; e.g., :author_as_recorded
    #   DELIMITER_MAP :: a map of delimiters to replace in the recon CSV values: { ORIGINAL => REPLACEMENT}; e.g., { '|' => ';' }
    #   METHOD_NAME :: the name of the DS::Extractor methods; e.g., [:extract_places]
    #   BALANCED_COLUMNS :: the columns that must have equal numbers of subfields; e.g., { places: [:structured_value, :authorized_label] }
    #
    module ReconType

      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods

        # Returns the set name of the recon set; e.g., :places
        #
        # Used to find a recon type configuration by name; either
        # the ReconType (like Recon::Type::Places) or the path to the
        # recon data dictionary CSV in the ds-data git repo as defined
        # in config/settings.yml:
        #
        #   ds:
        #     recon:
        #       ...
        #       sets:
        #         - name: :places
        #           repo_path: terms/reconciled/places.csv
        #           key_column: place_as_recorded
        #           ...
        #
        # @return [Symbol] the set name
        def set_name
          self::SET_NAME
        end

        # Returns the recon CSV headers; e.g., [:place_as_recorded, :authorized_label, :structured_value, :ds_qid]
        #
        # @return [Array<Symbol>] the recon CSV headers
        def recon_csv_headers
          self::RECON_CSV_HEADERS
        end

        # Returns lookups should pulls from the data dictionaries; e.g., [:authorized_label, :structured_value, :ds_qid]
        #
        # @return [Array<Symbol>] the lookup columns
        def lookup_columns
          self::LOOKUP_COLUMNS
        end

        # Returns the columns used to make the lookup key for the data dictionary; e.g., [:genre_as_recorded, :vocabulary]
        #
        # @return [Array<Symbol>] the key columns
        def key_columns
          self::KEY_COLUMNS
        end

        # Returns the column in the recon CSV that holds the as-recorded value; e.g., :author_as_recorded
        #
        # @return [Symbol] the import CSV as recorded column
        def as_recorded_column
          self::AS_RECORDED_COLUMN
        end

        # Returns the delimiter repalcement map: { ORIGINAL => REPLACEMENT}; e.g., { '|' => ';' }
        #
        # @return [Hash<Symbol,String>] the delimiter map
        def delimiter_map
          self::DELIMITER_MAP
        end

        # Returns the name of the DS::Extractor methods; e.g., [:extract_places]
        #
        # @return [Array<Symbol>] the method name
        def method_name
          self::METHOD_NAME
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
        #   Recon::Type::Materials.balanced_columns #=> [:structured_value, :authorized_label]
        def balanced_columns
          self::BALANCED_COLUMNS
        end

        ##
        # Return the values of the key columns in the given row.
        #
        # @param row [Hash<Symbol,String>] The row to extract values from.
        # @return [Array<String>] The values of the key columns in the given row.
        def get_key_values row
          key_columns.map { |key| row[key] }
        end

        def lookup_values row
          lookup_columns.map { |key| row[key] }
        end
      end
    end
  end
end
