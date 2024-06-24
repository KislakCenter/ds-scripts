require 'nokogiri'

module Recon
  module Type
    class Titles

      extend DS::Util
      include ReconType

      SET_NAME = :titles

      METHOD_NAME = %i{ extract_titles }

      RECON_CSV_HEADERS = %i{
      title_as_recorded
      title_as_recorded_agr
      uniform_title_as_recorded
      uniform_title_as_recorded_agr
      authorized_label
      ds_qid
    }

      LOOKUP_COLUMNS = %i{
      authorized_label
      ds_qid
    }

      KEY_COLUMNS = %i{ title_as_recorded }

      AS_RECORDED_COLUMN = :title_as_recorded

      DELIMITER_MAP = { '|' => ';' }

      BALANCED_COLUMNS = {}

    end
  end
end
