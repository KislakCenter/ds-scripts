require 'nokogiri'

module Recon
  ##
  # Extract named subjects for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # two columns: subject and authority number.
  #
  class NamedSubjects < Recon::Subjects

    def self._lookup_single term
      uris = Recon.look_up('named-subjects', value:  term, column: 'structured_value')
      uris.to_s.gsub '|', ';'
    end
  end
end