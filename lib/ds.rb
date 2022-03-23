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
    # - removes square brackets
    #
    # If +terminator+ is non-nil, the method removes any trailing punctuation and whitespace and appends +terminator+.
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
    # Given a pipe separated list of single years or ranges of years, return
    # a pipe- and semicolon-separated list of century integers. Year ranges
    # should be separated by the +^+ character, so that +-+ can unambiguously
    # be used for BCE years as negative integers (<tt>1099-1000 BCE</tt> =>
    # <tt>-1099^-1000</tt>)
    #
    # For example,
    #
    #     DS.transform_dates_to_centuries('1400')           # => '15'
    #     DS.transform_dates_to_centuries('1400^1499')      # => '15'
    #     DS.transform_dates_to_centuries('1325|1400^1499') # => '14|15'
    #     DS.transform_dates_to_centuries('890^1020')       # => '9;10;11'
    #     DS.transform_dates_to_centuries('-800^-701')      # => '-8'
    #
    # @param [String] dates a pipe separated list of single dates or date
    #    ranges: '1832', '1350^1520'
    # @return [String] a pipe-separated century integers
    def transform_dates_to_centuries dates
      return if dates.to_s.empty?
      dates.to_s.split('|').flat_map { |date_range|
        next [] if date_range.strip.empty? # don't process empty values
        # Adjust ranges to return sensible centuries for ranges like
        # '1400-1499' or '1401-1500'
        date_range = adjust_for_century date_range
        # turn the date/date range into a [min,max] array of century integers:
        #     1350-1550 => [14,16]
        #     1350      => [14]
        centuries = date_range.split('^').map { |i| calculate_century i }.sort
        # get an array for the range of centuries:
        #       [14,16] => 14, 15, 16
        # join them; throw away zero if range spans BCE/CE
        (centuries.first..centuries.last).to_a.reject(&:zero?).join ';' # join list of centuries by semicolons
      }.join '|'
    end

    ##
    # Adjust date ranges so that intended results are returned for century
    # values. Thus:
    #
    #      1400 to  1499     => 15th C. CE
    #      1401 to  1500     => 15th C. CE
    #
    # And, thus:
    #
    #     -1499 to -1400     => 15th C. BCE
    #     -1500 to -1401     => 15th C. BCE
    #
    # This method adjusts the end year for CE dates and the start
    # year for BCE dates as needed:
    #
    #     DS.adjust_for_century '1325'          # => '1325';        no change needed
    #     DS.adjust_for_century '1400^1499'     # => '1400^1499';   no change needed
    #     DS.adjust_for_century '1401^1500'     # => '1401^1499'
    #     DS.adjust_for_century '-1500^-1401'   # => '-1500^-1401'; no change needed
    #     DS.adjust_for_century '-1499^-1400'   # => '-1499^-1401'
    #
    # @param [String] range a single year or +^+-separated date range
    # @return [String] the range, adjusted if needed
    def adjust_for_century range
      # return a single date
      return range if range =~ %r{^-?\d+$}

      start_year, end_year = range.split('^')
      start_int, end_int = start_year.to_i, end_year.to_i

      # end dates divisible by 100 need to be reduced by one:
      #   1500 => 1499; -1500 => -1501
      end_int -= 1 if end_int % 100 == 0
      [start_int, end_int].uniq.join '^'
    end

    ##
    # Given a year, return to the corresponding century as an integer following
    # this pattern:
    #
    # - the 16th C. CE is years 1500 to 1599
    # - the 1st C. CE is years 0 to 99
    # - the 16th C. BCE is years -1599 to -1501
    #
    # Thus:
    #
    #     DS.calculate_century 1501   # =>  16
    #     DS.calculate_century 1600   # =>  17
    #     DS.calculate_century -1600  # => -16
    #     DS.calculate_century -1501  # => -16
    #     DS.calculate_century 1      # =>   1
    #     DS.calculate_century 0      # =>   1
    #
    # @param [Integer] year an integer year value
    # @return [Integer] an integer representation of the century
    def calculate_century year
      year_int = Integer year
      # year <=> 0 returns 1 if year > 0; -1 if year < 0; 0 if year == 0
      # 0 is a special year; its sign is 1 and its absolute value is 1
      sign =    year_int == 0 ? 1 : (year_int <=> 0)
      abs_val = year_int == 0 ? 1 : year_int.abs
      offset = sign < 0 ? 1 : 0

      # if year is 1501, sign == 1 and abs_val == 1501
      #     => 1 * ((1501 - 1)/100 +1) => 1 * (1500/100 + 1) => 1 * (15 + 1) = 16
      # if year is 1500, sign == 1 and abs_val == 1500
      #     => 1 * ((1500 - 1)/100 +1) => 1 * (1499/100 + 1) => 1 * (14 + 1) = 15
      sign * ((abs_val - offset)/100 + 1)
    end

    def timestamp
      DateTime.now.iso8601.to_s
    end

  end

  self.extend ClassMethods
end