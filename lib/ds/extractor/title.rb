# frozen_string_literal: true

module DS
  module Extractor
    class Title < BaseTerm
      attr_accessor :vernacular
      attr_accessor :title_type
      attr_accessor :uniform_title
      attr_accessor :uniform_title_vernacular

      def initialize as_recorded:, vernacular: nil, uniform_title: nil, uniform_title_vernacular: nil
        @vernacular               = vernacular
        @uniform_title            = uniform_title
        @uniform_title_vernacular = uniform_title_vernacular
        super(as_recorded: as_recorded)
      end

      def to_a
        # title_type is not included
        [as_recorded, vernacular, uniform_title, uniform_title_vernacular]
      end

      def to_h
        {
          as_recorded: as_recorded,
          title_as_recorded_agr: vernacular,
          uniform_title_as_recorded: uniform_title,
          uniform_title_as_recorded_agr: uniform_title_vernacular
        }
      end
    end
  end
end
