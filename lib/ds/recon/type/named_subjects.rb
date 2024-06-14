require 'nokogiri'

module Recon
  module Type
    ##
    # Extract named subjects for reconciliation CSV output.
    #
    # Return a two-dimensional array, each row is a term; and each row has
    # two columns: subject and authority number.
    #
    class NamedSubjects < Recon::Type::Subjects

      extend DS::Util
      SET_NAME = :'named-subjects'

      METHOD_NAME = %i{ extract_named_subjects }

      def self._lookup_single term, from_column:
        uris = Recon.lookup_single(SET_NAME, value: term, column: from_column)
        uris.to_s.gsub '|', ';'
      end

      def self.from_mets files
        raise NotImplementedError, "No method to process named subjects for DS METS"
      end

      def self.from_tei files
        raise NotImplementedError, "No method to process named subjects for TEI"
      end

    end
  end
end
