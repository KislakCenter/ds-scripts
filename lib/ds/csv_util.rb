require 'csv'

module DS
  module CSVUtil
    module ClassMethods
      def zip_columns csv_file, *columns
        data = []
        CSV.foreach csv_file, headers: true do |row|
          row_map = columns.map { |c| row[c].to_s.split '|' }

          first = row_map.shift
          until first.empty?
            r = []
            r << first.shift
            row_map.each do |col|
              r << (col.shift || '')
            end
            data << r
          end
        end
        data.sort! { |a,b| a.first <=> b.first }
        data.uniq
      end

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
        rows.each_with_index do |hash,index|
          hash.each do |column, value|
            split_chars = NESTED_COLUMNS.include?(column) ? %r{[;|]} : %r{\|}
            if value.to_s.split(split_chars).any? { |sub| sub =~ %r{\s+$} }
              valid = false
              STDERR.puts "WARNING: trailing whitespace in row #{index}, column #{column}, value: '#{value}'"
            end
          end
        end
        valid
      end
    end
    self.extend ClassMethods
  end
end