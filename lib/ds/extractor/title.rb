# frozen_string_literal: true

module DS
  module Extractor
    class Title
      attr_accessor :as_recorded
      attr_accessor :vernacular
      attr_accessor :title_type
      attr_accessor :uniform_title
      attr_accessor :uniform_title_vernacular

      def initialize as_recorded: nil, vernacular: nil, uniform_title: nil, uniform_title_vernacular: nil
        @as_recorded              = as_recorded
        @vernacular               = vernacular
        @uniform_title            = uniform_title
        @uniform_title_vernacular = uniform_title_vernacular
      end

      def to_a
        # title_type is not included
        [as_recorded, vernacular, uniform_title, uniform_title_vernacular]
      end
    end
  end
end
