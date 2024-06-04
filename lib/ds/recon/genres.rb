require 'nokogiri'
require_relative 'recon_type'

module Recon
  ##
  # Extract genre terms for reconciliation CSV output.
  #
  # Return a two-dimensional array, each row is a term; and each row has
  # three columns: term, vocabulary, and authority number.
  #
  class Genres

    extend DS::Util
    include ReconType

    SET_NAME = :genres

    CSV_HEADERS = %i{
      genre_as_recorded
      vocabulary
      source_authority_uri
      authorized_label
      structured_value
      ds_qid
    }

    LOOKUP_COLUMNS = %i{
      authorized_label
      structured_value
      ds_qid
    }

    KEY_COLUMNS = %i{
      genre_as_recorded
      vocabulary
    }

    SUBSET_COLUMN = :vocabulary

    AS_RECORDED_COLUMN = :genre_as_recorded

    DELIMITER_MAP = { '|' => ';' }

    METHOD_NAME = %i{ extract_genres }

    BALANCED_COLUMNS = {
      genres: %i{ structured_value authorized_label }
    }

    # Adds recon the 'authorized_label' and 'structured_value' columns
    # to each row in the given array.
    # @param [Array] rows an array of arrays :genre_as_recorded
    #       :vocabulary, :source_authority_uri
    # @return [Array] the updated rows
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
      }
    end


    protected

    def self._lookup_single term, vocab, from_column:
      uris = Recon.lookup(SET_NAME, subset: vocab, value: term, column: from_column)
      uris.to_s.gsub('|', ';')
    end
  end
end
