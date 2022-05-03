require_relative '../ds/ds10'
require_relative '../ds/marc_xml'
require_relative '../ds/openn_tei'
require_relative 'recon/names'
require_relative 'recon/places'
require_relative 'recon/subjects'
require_relative 'recon/genre_terms'

module Recon
  def self.sort_and_dedupe array
    if array.first.is_a? Array
      array.sort { |a,b| a.first <=> b.first }.uniq &:join
    else
      array.sort.uniq
    end
  end
end