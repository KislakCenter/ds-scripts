# frozen_string_literal: true

module DS
  module Extractor
    class Place
      attr_accessor :as_recorded

      def initialize as_recorded: nil
        @as_recorded = as_recorded
      end

      def to_a
        [as_recorded]
      end
    end
  end
end
