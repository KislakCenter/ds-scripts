# frozen_string_literal: true

module DS
  module Extractor

    class Language < BaseTerm

      attr_accessor :codes

      def initialize as_recorded:, codes: nil
        @codes       = codes
        super(as_recorded: as_recorded)
      end

      def to_a
        [as_recorded, codes]
      end
    end
  end
end
