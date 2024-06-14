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

      SUBSET_COLUMN = nil

      AS_RECORDED_COLUMN = :as_recorded

      DELIMITER_MAP = {}

      METHOD_NAME = []

      BALANCED_COLUMNS = {}


      def self.add_recon_values rows
        rows.each do |row|
          as_recorded = row.first
          row << _lookup_single(as_recorded, from_column: 'authorized_label')
        end
      end

      def self.from_tei files
        raise NotImplementedError, "No method to process splits for TEI"
      end

      def self.from_marc files
        raise NotImplementedError, "No method to process splits for MARC XML"
      end

      def self.from_mets files
        data = []
        process_xml files do |xml|
          data += DS::Extractor::DsMetsXmlExtractor.extract_recon_splits xml
        end
        add_recon_values data
        Recon.sort_and_dedupe data
      end

      def self.lookup as_recs, from_column: 'authorized_label'
        as_recs.map { |as_rec| _lookup_single as_rec, from_column: from_column }.join '|'
      end

      def self._lookup_single as_recorded, from_column:
        Recon.lookup_single(:splits, value: as_recorded, column: from_column)
      end

    end
  end
end
