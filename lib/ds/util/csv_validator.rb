# frozen_string_literal: true

module DS
  module Util
    class CsvValidator

      ERROR_UNBALANCED_SUBFIELDS     = 'Row has subfields of different lengths'
      ERROR_BLANK_SUBFIELDS          = 'Row has blank subfields'
      ERROR_MISSING_REQUIRED_COLUMNS = "CSV is missing required column(s)"

      # split on pipes that are not escaped with '\'
      PIPE_SPLIT_REGEXP     = %r{(?<!\\)\|}
      # split on pipes and semicolons that are not escaped with '\'
      PIPE_SEMICOLON_REGEXP = %r{(?<!\\)[;|]}

      # Validates a row of data against a set of required columns and balanced columns.
      #
      #   # validate a CSV row for required columns and balanced columns
      #   # columns a and b are required,
      #   # columns a and b, and c and d are balanced
      #   # balanced_columns keys are used as labels for the error messages
      #   required_columns = [:a, :b]
      #   balanced_columns = { group1: [:a, :b], group2: [:c: :d] }
      #   csv_validator.validate(row, required_columns: required_columns, balanced_columns: balanced_columns)
      #
      # @param row [Hash,CSV::Row] The row of data to be validated.
      # @param required_columns [Array<Symbol>] The required columns for the row.
      # @param balanced_columns [Hash<Symbol, Array<Symbol>>] a hash of groups of balanced columns; see example above
      # @param allow_blank [Boolean] Whether to allow blank subfields in balanced columns
      # @return [Array<String>] An array of error messages, if any.
      def self.validate_row row, required_columns: [], balanced_columns: {}, nested_columns: {}, allow_blank: false
        errors = []
        errors += validate_required_columns(row, required_columns)
        errors += validate_balanced_columns(row, balanced_columns: balanced_columns, allow_blank: allow_blank)
        errors += validate_whitespace(row, nested_columns: nested_columns)
        errors
      end

      # Validates the presence of required columns in a given row of data.
      #
      # @param row [Hash, CSV::Row] The row of data to be validated.
      # @param required_columns [Array<Symbol>] The required columns for the row.
      # @return [Array<String>] An array of error messages, if any; otherwise, an empty array.
      def self.validate_required_columns row, required_columns
        missing = required_columns - row.keys
        return [] if missing.empty?
        ["#{ERROR_MISSING_REQUIRED_COLUMNS}: #{missing.join ', '}"]
      end


      # Validates the balanced columns in a given row of data.
      #
      # +balanced_columns+ is a hash of groups of balanced columns.
      #
      # @param row [Hash] The row of data to be validated.
      # @param balanced_columns [Hash<Symbol, Array<Symbol>>] A hash of groups of balanced columns.
      # @param allow_blank [Boolean] Whether to allow blank subfields in balanced columns.
      # @return [Array<String>] An array of error messages, if any; otherwise, an empty array.
      #
      # @example
      #     # row has unbalanced columns :a and :b
      #     row = { a: 'a', b: 'b|b', c: 'c', d: 'd' }
      #     balanced_columns = { group1: [:a, :b] }
      #     csv_validator.validate_balanced_columns(
      #         row, balanced_columns: balanced_columns
      #     )  # => ["Row has subfields of different lengths: group: :group1, sizes: [1, 2], row: [\"a\", \"b|b\"]"]
      def self.validate_balanced_columns row, balanced_columns: {}, allow_blank: false
        return [] if balanced_columns.blank?
        errors = []
        balanced_columns.each { |group, columns|
          values = columns.map { |column| row[column.to_s] || row[column.to_sym] }
          errors += validate_row_splits(group: group, row_values: values, allow_blank: allow_blank)
        }
        errors
      end

      # Maximum number of subfields to allow in a row; this number is
      # arbitrarily set to 100,000 to ensure all trailing empty
      # values are included in the array output by split.
      MAX_SPLITS = 100000


      ##
      # Return an error if each value in +row_values+ has the same number of subfields
      # **and** none of the subfields are blank; otherwise, return +nil+.
      #
      # If +allow_blank+ is +true+, ignore blanks, only check for balanced
      # subfields.
      #
      # Note: It is always allowed for every value to be blank (empty string).
      #
      # So:
      #
      #   [ 'a|b|c', '1|2|3' ]   # => valid, return nil
      #   [ '', '' ]             # => valid, return nil
      #   [ 'a|b|c', '1|2' ]     # => not valid, return ERROR_UNBALANCED_SUBFIELDS
      #   [ 'a||c', '1|2|3' ]    # => not valid, return ERROR_BLANK_SUBFIELDS
      #   [ 'a||c', '1|2|3' ]    # => valid, if allow_blank == true, return nil
      #
      # @param [Array<String>] row_values an array of strings from one or more columns
      # @param [String] separators a list of allowed subfield separators; e.g., ';', '|', ';|'
      # @param [Boolean] allow_blank whether any of the subfields may be blank
      # @return [Array<String>] the row errors, or [] if there are no errors
      def self.validate_row_splits row_values: [], separators: '|;', allow_blank: false, group: nil
        errors = []
        return errors if row_values.all? { |val| val.to_s.strip.empty? }
        # Input array is an array of two or more strings that must split into
        # equal numbers of subfields.
        #
        #   ['a|bc', '1|2|3'] => [['a', 'b', 'c'],
        #                         ['1', '2', '3']]
        #   ['a|b|c', '1|2']  => [['a', 'b', 'c'],
        #                         ['1' '2']]
        #
        # Count the subfields and make sure there's an equal number in each field
        #
        #    ['a|bc', '1|2|3'] => # 3 subfields each; => valid
        #    ['a|b|c', '1|2']  => # 2 and 3 subfields; => not valid
        splits = row_values.map { |v|
          v.split %r{[#{Regexp.escape separators}]}, MAX_SPLITS
        }
        # there should be only one subfield length:
        sizes = splits.map { |vals| vals.size }
        if sizes.uniq.size > 1
          errors << "#{ERROR_UNBALANCED_SUBFIELDS}: group: #{group.inspect}, sizes: #{sizes.inspect}, row: #{row_values.inspect}"
        end

        # return true if we don't have check for blanks
        return errors if allow_blank

        # return an error if any of the subfields are blank
        if splits.flatten.any? &:blank?
          errors << "#{ERROR_BLANK_SUBFIELDS}: group: #{group.inspect}, row: #{row_values.inspect}"
        end
        errors
      end

      # Validates a row of data for trailing whitespace. Returns an
      # error for each column that contains trailing whitespace.
      #
      # Nested columns is a hash with column names as keys and group
      # names as values; e.g.,
      #
      #     nested_columns = {
      #       "subject_label" => :subjects,
      #       "subject" => :subjects,
      #       "genre_label" => :genres
      #       "genre" => :genres
      #     }
      #
      # @param row [Hash] The row of data to be validated.
      # @param nested_columns [Hash<String, Symbol] A hash of nested columns.
      # @return [Array<String>] An array of error messages, if any.
      def self.validate_whitespace row, nested_columns: {}
        errors = []

        row.each do |column, value|
          # Assume all columns can have subfields delimited by pipes;
          # some columns are "nested"; that is, they can be be further
          # subdivided by semicolons. Select the regexp for the
          # subfield type
          split_chars = nested_columns.include?(column) ? PIPE_SEMICOLON_REGEXP : PIPE_SPLIT_REGEXP
          if value.to_s.split(split_chars).any? { |sub| sub =~ %r{\s+$} }
            group = nested_columns[column]
            errors << "WARNING: trailing whitespace found group: #{group}, column #{column}, value: '#{value}'"
          end
        end

        errors
      end

    end
  end
end
