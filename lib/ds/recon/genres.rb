require 'nokogiri'

module Recon
  ##
  # Extract genre terms for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # three columns: term, vocabulary, and authority number.
  #
  class Genres

    extend DS::Util
    CSV_HEADERS = %w{
      genre_as_recorded
      vocabulary
      source_authority_uri
      authorized_label
      structured_value
    }

    def self.add_recon_values rows
      rows.each do |row|
        term, vocab, _ = row
        row << _lookup_single(term, vocab, from_column: 'authorized_label')
        row << _lookup_single(term, vocab, from_column: 'structured_value')
      end
      rows
    end

    def self.lookup genres, vocabs, from_column: 'structured_value'
      genres.zip(vocabs).map { |term, vocab|
        _lookup_single term, vocab, from_column: from_column
      }.join '|'
    end

    def self.from_marc files
      data = []
      process_xml files, remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          data += DS::Extractor::MarcXML.extract_recon_genres record, sub_sep: '--'
        end
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    def self.from_mets files
      raise NotImplementedError, "No method to process genres for DS METS"
    end

    def self.from_tei files
      data = []
      process_xml files, remove_namespaces: true do |xml|
        data += DS::Extractor::OPennTEI.extract_recon_genres xml
      end
      add_recon_values data
      Recon.sort_and_dedupe data
    end

    protected

    def self._lookup_single term, vocab, from_column:
      uris = Recon.lookup('genres', subset: vocab, value: term, column: from_column)
      uris.to_s.gsub('|', ';')
    end
  end
end