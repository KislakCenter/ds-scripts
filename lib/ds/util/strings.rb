# frozen_string_literal: true

module DS
  module Util
    module Strings

      ##
      # This method calls
      #
      #  - +convert_mets_superscript+
      #  - +remove_brackets+
      #  - +fix_double_periods+
      #  - +escape_pipes+
      #  - +normalize_string+
      #
      # If +terminator+ is non-nil, the method removes any trailing
      # punctuation and whitespace and appends +terminator+.
      #
      # Set +terminator+ to +``+ (empty string) to remove trailing
      # punctuation.
      #
      # @param [String] string the string to clean
      # @param [String] terminator the terminator to use, if any
      # @param [Boolean] force use exact termination with +terminator+
      # @return [String] the cleaned string
      def clean_string string, terminator: nil, force: false
        normal = normalize_string(
          escape_pipes(
            fix_double_periods(
              remove_brackets(
                convert_mets_superscript(string.to_s)
              )
            )
          )
        )

        return normal if terminator.nil?

        cleaned = terminate normal, terminator: terminator, force: force
        # keep cleaning until no changes are made
        return clean_string cleaned unless cleaned == string
        cleaned
      end

      # TERMINAL_PUNCT_REGEX matches strings terminated by any of +.,;:?!+
      TERMINAL_PUNCT_REGEX =  %r{\s*([.,;:?!]+)("?)$}

      # ELLIPSIS_REGEX matches strings terminated by +...+
      ELLIPSIS_REGEX       = %r{\.\.\."?$}

      # ABBREV_REGEX matches values like 'N.T.', 'O.T.'
      ABBREV_REGEX         = %r{\W[A-Z]\.$}
      ##
      # Add termination to string if it lacks terminal punctuation.
      # Terminal punctuation is one of
      #
      #     . , ; : ? !
      #
      # When +:terminator+ is +''+ or +nil+, trailing punctuation is*always*
      # removed.
      #
      # Strings ending with ellipsis, '...' or '..."' are returned unaltered. This
      # behavior cannot be overridden with `:force`.
      #
      # @param [String] str the string to terminate
      # @param [String] terminator the terminator to use; default: +.+
      # @param [Boolean] force use exact termination with +terminator+
      # @return [String]
      def terminate str, terminator: '.', force: false
        str.strip!
        # DE 2022.08.12 Note the \s* to match and replace whitespace before
        #     punctuation; this addresses a bug where some strings were returned
        #     with trailing whitespace: 'value :' => 'value '
        # TODO: Refactor? Two functions: strip_punctuation(), terminate() ??

        # don't strip ellipses
        return str if str =~ ELLIPSIS_REGEX
        # don't strip final periods for strings like "N.T."
        return str if str =~ ABBREV_REGEX

        # if :terminator is '' or nil, remove any terminal punctuation
        return str.sub TERMINAL_PUNCT_REGEX, '\2' if terminator.blank?

        # str is already terminated
        return str if str.end_with? terminator
        return str if str.end_with? %Q{#{terminator}"}

        # str lacks terminal punctuation; add it;
        #  \\1 => keep final '"' (double-quote)
        return str.sub %r{("?)$}, "#{terminator}\\1" if str !~ TERMINAL_PUNCT_REGEX
        # str has to have exact terminal punctuation
        #  \\1 => keep final '"' (double-quote)
        return str.sub TERMINAL_PUNCT_REGEX, "#{terminator}\\2" if force
        # string has some terminal punctuation; return it
        str
      end

      ##
      # Strip and replace all sequences of white space with single
      # spaces and apply Unicode normalization. NFC normalization is
      # used for all strings except URLs, to which NFKC normalization
      # is applied. See RFC 3987:
      #
      # https://datatracker.ietf.org/doc/html/rfc3987#section-5.3.2.2
      #
      # @param [String] value the string to normalize
      # @return [String] the normalized string
      def normalize_string value
        form = is_url?(value) ? :nfkc : :nfc
        escape_pipes(
          clean_white_space(
            unicode_normalize(value, form)
          )
        )
      end

      ##
      # converts encoded DS 1.0 encoded superscripts to parenthetical
      # values; e.g., 'XVI#^4/4#' is converted to 'XVI(4/4)'
      def convert_mets_superscript value
        value.to_s.gsub(%r{#\^([^#]+)#}, '(\1)')
      end

      ##
      # Escape pipe characters in source strings so split operations
      # can avoid splitting on them.
      def escape_pipes value
        value.gsub('|', '\|')
      end

      def clean_white_space value
        value.to_s.strip.gsub(%r{\s+}, ' ')
      end

      ##
      # Return the string using unicode normalization form +form+.
      # Use +NFC+ normalization by default. NFC normalization is
      # recommended best practice. See
      #
      # https://www.honeybadger.io/blog/ruby-unicode-normalization/
      #
      # In short: NFC should be used for most strings, but NFKC for
      # URLs. See RFC 3987:
      #
      # https://datatracker.ietf.org/doc/html/rfc3987#section-5.3.2.2
      #
      # Wikibase uses NFC normalization:
      #
      # https://doc.wikimedia.org/Wikibase/REL1_28/php/classWikibase_1_1Repo_1_1Parsers_1_1WikibaseStringValueNormalizer.html
      #
      # @param [String] value the string to normalize
      # @param [Symbol] form the normalization form: +:nfc+, +:nfkc+.
      #       +:nfd+, or +:nfkd+; default: +:nfc+
      # @return [String] the normalized string
      def unicode_normalize value, form = :nfc
        value.to_s.unicode_normalize form
      end

      def remove_brackets value
        value.to_s.strip.delete_prefix('[').delete_suffix(']')
      end

      ##
      # Replace any sequence of two '..' with a single period.
      # Ellipses, that is, sequences of three periods '...', are
      # ignored.
      #
      #     fix_double_periods('....')       #  => "...."
      #     fix_double_periods('.. ..')      #  => ". ."
      #     fix_double_periods('... ..')     #  => "... ."
      #     fix_double_periods('... a..')    #  => "... a."
      #     fix_double_periods('a... a..')   #  => "a... a."
      #
      # @param [String] value the string to process
      # @return [String]
      def fix_double_periods value
        value.to_s.gsub(%r{(?<!\.)\.\.(?!\.)}, '.')
      end

      def is_url? value
        value.to_s =~ URI::regexp
      end
    end
  end
end