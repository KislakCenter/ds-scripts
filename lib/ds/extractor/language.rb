# frozen_string_literal: true

module DS
  module Extractor

    class Language

      attr_accessor :as_recorded
      attr_accessor :codes

      def initialize as_recorded: nil,codes: nil
        @as_recorded = as_recorded
        @codes       = codes
      end

      def to_a
        [as_recorded, codes]
      end
    end
  end
end
