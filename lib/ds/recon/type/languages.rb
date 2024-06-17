module Recon
  module Type
    class Languages

      extend DS::Util
      include Recon::Type::ReconType

      SET_NAME = :languages

      RECON_CSV_HEADERS = %i{
      language_as_recorded
      language_code
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
      language_as_recorded
    }

      AS_RECORDED_COLUMN = :language_as_recorded

      DELIMITER_MAP = {}

      METHOD_NAME = %i{ extract_languages }

      BALANCED_COLUMNS = { languages: %w{ structured_value authorized_label } }

    end
  end
end
