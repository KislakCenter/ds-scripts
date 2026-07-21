# frozen_string_literal: true

module DS
  module Extractor
    class BaseRecordLocator

      attr_reader :errors

      def initialize
        @errors = []
      end

      def locate_record parsed_source, lookup_value, lookup_value_location
        raise NotImplementedError
      end


      def add_error message

        @errors << message
      end
    end
  end
end
