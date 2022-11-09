require 'nokogiri'

module Recon
  ##
  # Lookup subjects and named subjects for import CSV output
  #
  class AllSubjects < Recon::Subjects

    extend DS::Util

    def self._lookup_single term, from_column:
      uris = Recon.lookup('all-subjects', value: term, column: from_column)
      uris.to_s.gsub '|', ';'
    end
  end
end