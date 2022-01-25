require_relative './ds/constants'
require_relative './ds/ds10'
require_relative './ds/openn_tei'
require_relative './ds/marc_xml'

module DS
  include DS::Constants

  module ClassMethods
    ##
    # This method:
    #
    # - converts encoded DS 1.0 encoded superscripts to parenthetical values; e.g., 'XVI#^4/4#' is converted to 'XVI(4/4)'
    # - cleans tabs, newlines and duplicate spaces with a single +' '+
    # - removes isolated pairs of period characters, which show up for some reason
    # - remove square brackets
    #
    # If +terminator+ is non-nil, the method
    #
    # - removes any trailing punctuation and whitespace and append +terminator+.
    #
    # Set +terminator+ to +``+ (empty string) to remove trailing punctuation.
    #
    # A string with leading and trailing whitespace is returned.
    #
    # @param [String] string the string to clean
    # @param [String] terminator the terminator to use, if any
    # @return [String] the cleaned string
    def clean_string string, terminator: nil
      # handle DS legacy superscript encoding, whitespace, duplicate '.'
      # remove trailing punctuation only if a terminator is specified (see below)
      # %r{(?<!\.)\.{2}(?!\.)} => two periods `\.{2}` when not preceded by a period (?<!\.) and not followed by a period (?!\.)
      normal = string.to_s.gsub(%r{#\^([^#]+)#}, '(\1)').gsub(%r{\s+}, ' ').strip.gsub(%r{(?<!\.)\.\.(?!\.)}, '.').delete '[]'

      return normal if terminator.nil?

      # terminator is present; append it after any removing trailing whitespace and punctuation
      "#{normal.sub(%r{[[:punct:][:space:]]+$}, '').strip}#{terminator}"
    end

    def find_qid inst_alias
      # try without changes; and then normalize
      DS::INSTITUTION_NAMES_TO_QID[inst_alias] or
        DS::INSTITUTION_NAMES_TO_QID[inst_alias.to_s.strip] or
        DS::INSTITUTION_NAMES_TO_QID[inst_alias.to_s.strip.downcase]
    end

    def preferred_inst_name inst_alias
      url = find_qid inst_alias
      return unless url =~ %r{Q\d+$}
      qid = Regexp.last_match[0]
      DS::QID_TO_INSTITUTION_NAMES[qid].first
    end

    ##
    # Given date range like '1350-1520', return a pipe-separated list of Getty
    # AAT century URIs.
    #
    # @param [String] dates a pipe separated list of single dates or dats
    #    ranges: '1832', '1350-1520'
    # @return [String] a pipe-separated list of AAT URIs
    def transform_date_to_century dates
      return if dates.to_s.empty?
      dates.split('|').flat_map { |date|
        next [] if date.strip.empty? # don't process empty values
        # turn the date/date range into an array of century integers:
        #     1350-1550 => [14,16]
        centuries = date.split(/-/).map { |i| i.to_i / 100 + 1 }.sort
        # then we get an array for the range of centuries:
        #       [14,16] => 14, 15, 16
        # and we look up each AAT URI for those values
        (centuries.first..centuries.last).to_a.map { |c|
          lookup_century c
        }.join '-'
      }.uniq.join '|'
    end

    def timestamp
      DateTime.now.iso8601.to_s
    end

    protected
    @@centuries = nil

    ##
    # Look up the URI for +century+, where century is an integer like +1+, +12+,
    # +-3+, etc.
    # Values are read in from the file `data/getty-aat-centuries.csv` and
    # converted to a hash of Getty AAT century URIs. Keys are century integers,
    # like '1', '2', '3', '-1', '-2', '-3', etc. and values are AAT URIs.
    #
    # @param [Integer] century an integer like +1+, +12+, +-3+, etc.
    # @return [String] the AAT URI for the century
    def lookup_century century
      if @@centuries.nil?
        path = File.expand_path '../ds/data/getty-aat-centuries.csv', __FILE__

        # aat_id,label,number
        # http://vocab.getty.edu/aat/300404465,fifteenth century (dates CE),15
        # http://vocab.getty.edu/aat/300404493,first century (dates CE),1
        @@centuries = CSV.read(path).inject({}) do |h, row|
          if row.first == 'aat_id'
            h
          else
            h.update({ row.last => row.first })
          end
        end.freeze
      end
      @@centuries[century.to_s]
    end

  end

  self.extend ClassMethods
end