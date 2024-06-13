require 'nokogiri'

module Recon
  module Type
    ##
    # Extract genre terms for reconciliation CSV output.
    #
    # Return a two-dimensional array, each row is a term; and each row has
    # three columns: term, vocab, and authority number.
    #
    class Genres

      extend DS::Util
      include ReconType

      SET_NAME = :genres

      CSV_HEADERS = %i{
      genre_as_recorded
      vocab
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
      vocab
    }

      SUBSET_COLUMN = :vocab

      AS_RECORDED_COLUMN = :genre_as_recorded

      DELIMITER_MAP = { '|' => ';' }

      METHOD_NAME = %i{ extract_genres }

      BALANCED_COLUMNS = {
        genres: %i{ structured_value authorized_label }
      }

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
end
