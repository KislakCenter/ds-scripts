require 'nokogiri'

module Recon
  ##
  # Lookup subjects and named subjects for import CSV output
  #
  class AllSubjects < Recon::Subjects

    extend DS::Util

    SET_NAME = :'all-subjects'

    def self._lookup_single term, from_column:
      uris = Recon.lookup(SET_NAME, value: term, column: from_column)
      uris.to_s.gsub '|', ';'
    end
  end
end
