# frozen_string_literal: true

module DS
  module Extractor

    class Language < BaseTerm

      attr_accessor :codes

      def initialize as_recorded:, codes: Set.new
        @codes       = codes
        super(as_recorded: as_recorded)
      end

      def to_a
        [as_recorded, codes]
      end

      def to_h
        {
          as_recorded: as_recorded,
          language_code: codes.join(';')
        }
      end
    end
  end
end
