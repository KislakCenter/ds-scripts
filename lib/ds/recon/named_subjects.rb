require 'nokogiri'

module Recon
  ##
  # Extract named subjects for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # two columns: subject and authority number.
  #
  class NamedSubjects < Recon::Subjects

    def self._lookup_single term, from_column:
      uris = Recon.lookup('named-subjects', value: term, column: from_column)
      uris.to_s.gsub '|', ';'
    end
  end
end