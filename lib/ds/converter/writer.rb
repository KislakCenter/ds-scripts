# frozen_string_literal: true

module DS
  module Converter
    class Writer

      attr_reader :count
      attr_reader :output
      attr_reader :validator


      def initializer output_io, row_validator
        @output = output_io
        @count = 1
        @validator = row_validator
        @valid = true
        @errors = []
      end

      def write
        converter.convert do |row|
          CSV.open output, "w", headers: true do |csv|
            csv << DS::HEADINGS if count == 1
            count += 1
            validate_row count, row
            csv << row
          end
        end
      end

      def valid?
        errors.blank?
      end

      def validate_row row_num, row
        error = validator.row_valid? row
        return unless row
        add_error row_num, error
      end

      def add_error row_num, error
        @errors << [row_num, error]
      end

      def errors
        @errors.dup
      end
    end
  end
end