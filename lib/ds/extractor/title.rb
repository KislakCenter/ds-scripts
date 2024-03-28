# frozen_string_literal: true

module DS
  module Extractor
    class Title
      attr_accessor :as_recorded
      attr_accessor :vernacular
      attr_accessor :title_type

      def initialize as_recorded: nil, vernacular: nil, title_type: nil
        @as_recorded = as_recorded
        @vernacular  = vernacular
        @title_type  = title_type
      end

      def to_a
        # title_type is not included
        [as_recorded, vernacular]
      end
    end
  end
end
