require 'nokogiri'

module Recon
  ##
  # Extract subjects for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # two columns: subject and authority number.
  #
  class Subjects
    def self.add_recon_values rows
      rows.each do |row|
        term, _ = row
        row << _lookup_single(term, from_column: 'structured_value')
      end
    end

    def self.from_marc files, tags: []
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.collect_recon_datafields record, tags: tags, codes: ('a'..'z').to_a, sub_sep: '--'
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.lookup terms, from_column: 'structured_value'
      terms.map { |term| _lookup_single term, from_column: from_column }.join '|'
    end

    def self.from_mets files
      raise NotImplementedError
    end

    def self.from_tei files
      raise NotImplementedError
    end

    def self._lookup_single term, from_column:
      uris = Recon.lookup('subjects', value: term, column: from_column)
      uris.to_s.gsub '|', ';'
    end
  end
end