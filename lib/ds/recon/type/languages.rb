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

      SUBSET_COLUMN = nil

      DELIMITER_MAP = {}

      METHOD_NAME = %i{ extract_languages }

      BALANCED_COLUMNS = { languages: %w{ structured_value authorized_label } }

      def self.lookup languages, from_column: 'structured_value', separator: '|'
        languages.split(separator).map { |lang|
          # make sure each group of languages is separated by ';'
          Recon.lookup_single(SET_NAME, value: lang, column: from_column).gsub('|', ';')
        }
      end

      ##
      # Extract all the codes from the pairs of language_as_recorded and code
      # value in +data+, and add each code to data, e.g., +lat+, as a
      # language +[name,code]+ pair, e.g.,
      #
      #     [ 'lat', 'lat']
      #
      # Input +data+ will be, for example,
      #
      #     [
      #       ["Latin, with a few poems in Italian (f. 106r-108v).", "lat|ita"],
      #       ["Persian.", "per"],
      #       ["Spanish.", "spa"],
      #       ["Middle French.", "frm"],
      #       ["eng", "eng"],
      #       ["In Italian.", "ita"],
      #       ["Middle English.", "enm"],
      #       ["Middle English.", "eng|enm"]
      #     ]
      #
      # This method will add all the codes to this array, thus:
      #
      #     [
      #       ["Latin, with a few poems in Italian (f. 106r-108v).", "lat|ita"],
      #       ["Persian.", "per"],
      #       ["Spanish.", "spa"],
      #       ["Middle French.", "frm"],
      #       ["eng", "eng"],
      #       ["In Italian.", "ita"],
      #       ["Middle English.", "enm"],
      #       ["Middle English.", "eng|enm"],
      #       ['lat', 'lat'],
      #       ['ita', 'ita'],
      #       ['per', 'per'],
      #       ['spa', 'spa'],
      #       ['frm', 'frm'],
      #       ["eng", "eng"],
      #       ['enm', 'enm'],
      #       # etc.
      #     ]
      # @param [Array<Array<String>>] data an array of pairs language names and codes
      def self.expand_codes data, separator: '|'
        data.uniq.map(&:last).flat_map { |codes|
          codes.split separator
        }.sort.uniq.each do |code|
          data << [code, code]
        end
      end
    end
  end
end
