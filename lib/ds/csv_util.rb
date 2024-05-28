require 'csv'

module DS
  module CSVUtil
    module ClassMethods
      # TODO: These methods don't belong in CSVUtil; find them a new home
      # TODO: Remove CSVUtil when the above TODO is complete
      # Columns with two levels of subfields, separated by '|' and ';'
      NESTED_COLUMNS = %w{ subject subject_label genre genre_label production_place production_place_label language language_label }
      ##
      # Check all rows for validation errors, including:
      #
      #   - trailing spaces in values
      #
      # @param [Array<Hash>] rows the CSV rows
      # @return [Boolean]
      def validate rows
        valid = true
        rows.each_with_index do |row,index|
          valid = false unless row_valid? row, index
        end
        valid
      end

      # split on pipes that are not escaped with '\'
      PIPE_SPLIT_REGEXP = %r{(?<!\\)\|}
      # split on pipes and semicolons that are not escaped with '\'
      PIPE_SEMICOLON_REGEXP = %r{(?<!\\)[;|]}


      def row_valid? row, index
        valid       = true
        DS::Util::CsvValidator.validate_whitespace(row, row_num: index, nested_columns: NESTED_COLUMNS).each do |error|
          valid = false
          STDERR.puts "WARNING: #{error}"
        end
        # row.each do |column, value|
        #   split_chars = NESTED_COLUMNS.include?(column) ? PIPE_SEMICOLON_REGEXP : PIPE_SPLIT_REGEXP
        #   if value.to_s.split(split_chars).any? { |sub| sub =~ %r{\s+$} }
        #     valid = false
        #     STDERR.puts "WARNING: trailing whitespace in row #{index}, column #{column}, value: '#{value}'"
        #   end
        # end
        valid
      end
    end

    self.extend ClassMethods
  end
end
