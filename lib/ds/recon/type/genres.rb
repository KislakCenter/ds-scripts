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

      RECON_CSV_HEADERS = %i{
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

      AS_RECORDED_COLUMN = :genre_as_recorded

      DELIMITER_MAP = { '|' => ';' }

      METHOD_NAME = %i{ extract_genres }

      BALANCED_COLUMNS = {
        genres: %i{ structured_value authorized_label }
      }

    end
  end
end