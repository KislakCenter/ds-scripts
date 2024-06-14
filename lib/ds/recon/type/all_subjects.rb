require 'nokogiri'

module Recon
  module Type
    ##
    # Lookup subjects and named subjects for import CSV output
    #
    class AllSubjects < Recon::Type::Subjects

      extend DS::Util

      SET_NAME = :'all-subjects'

      METHOD_NAME = %i{ extract_all_subjects  }

      # A method to look up a single term in a specified column.
      #
      # @param [String] term the term to look up
      # @param [Symbol] from_column the column value to retrieve
      # @return [String] the URIs with '|' replaced by ';'
      def self._lookup_single term, from_column:
        uris = Recon.lookup_single(SET_NAME, value: term, column: from_column)
        uris.to_s.gsub '|', ';'
      end
    end
  end
end
