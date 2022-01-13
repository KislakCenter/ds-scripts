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

    def transform_date_to_century date
      return if date.nil?
      century = []
      date.split('-').each do |d|
        if d.length <= 3
          century << (d[0].to_i + 1).to_s
        else
          century << (d[0..1].to_i + 1).to_s
        end
      end
      century.uniq.join '-'
    end

    def timestamp
      DateTime.now.iso8601.to_s
    end
  end

  self.extend ClassMethods
end