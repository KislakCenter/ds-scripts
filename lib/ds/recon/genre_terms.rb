require 'nokogiri'

module Recon
  ##
  # Extract genre terms for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # three columns: term, vocabulary, and authority number.
  #
  class GenreTerms
    def self.add_recon_values rows
      rows.each do |row|
        term, vocab, _ = row
        row << _lookup_single(term, vocab)
      end
    end

    def self.from_marc files
      data = []
      files.each do |in_xml|
        xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
        xml.remove_namespaces!
        xml.xpath('//record').each do |record|
          data += DS::MarcXML.extract_recon_genres record, sub_sep: '--'
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      raise NotImplementedError
    end

    def self.from_tei files
      raise NotImplementedError
    end

    protected

    def self._lookup_single term, vocab
      column = vocab == 'aat' ? 'genre_aat' : 'genre_fast'
      uris = Recon.look_up('genres', subset: vocab, key: term, column: column)
      uris.to_s.gsub('|', ';')
    end
  end
end