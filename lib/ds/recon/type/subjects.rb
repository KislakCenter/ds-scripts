require 'nokogiri'

module Recon
  module Type
    ##
    # Extract subjects for reconciliation CSV output.
    #
    # NOTE: Each source subject extraction method should return a two dimensional
    # array:
    #
    #     [["Islamic law--Early works to 1800", ""],
    #       ["Malikites--Early works to 1800", ""],
    #       ["Islamic law", ""],
    #       ["Malikites", ""],
    #       ["Arabic language--Grammar--Early works to 1800", ""],
    #       ["Arabic language--Grammar", ""],
    #       ...
    #       ]
    #
    # The two values are `subject_as_recorded` and `source_authority_uri`. The
    # second of these is present when the source record provides an accompanying
    # URI. This is rare. Sources the lack a URI should return the as recorded
    # value and `""` (the empty string) for the `source_authority_uri` as shown
    # above.
    #
    class Subjects

      extend DS::Util
      include ReconType

      SET_NAME = :subjects

      RECON_CSV_HEADERS = %i{
      subject_as_recorded
      subfield_codes
      vocab
      source_authority_uri
      authorized_label
      structured_value
      ds_qid
    }.freeze

      LOOKUP_COLUMNS = %i{
      authorized_label
      structured_value
      ds_qid
    }

      KEY_COLUMNS = %i{
      subject_as_recorded
      subfield_codes
      vocab
    }

      METHOD_NAME = %i{ extract_subjects }

      BALANCED_COLUMNS = { subjects: %i{ structured_value authorized_label } }

      AS_RECORDED_COLUMN = :subject_as_recorded

      DELIMITER_MAP = { '|' => ';' }

    end
  end
end
