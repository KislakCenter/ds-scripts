require 'nokogiri'

module Recon
  ##
  # Extract subjects for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # two columns: subject and authority number.
  #
  class Subjects
    def self.from_marc files, tags: []
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.collect_recon_datafields record, tags: tags, codes: ('a'..'z').to_a, sub_sep: '--'
        end
      end
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      raise NotImplementedError
    end

    def self.from_tei files
      raise NotImplementedError
    end
  end
end