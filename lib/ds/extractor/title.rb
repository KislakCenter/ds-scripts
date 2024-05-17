# frozen_string_literal: true

module DS
  module Extractor
    class Title < BaseTerm
      attr_accessor :vernacular
      attr_accessor :title_type
      attr_accessor :uniform_title
      attr_accessor :uniform_title_vernacular

      # Initializes a new Title object.
      #
      # Parameters:
      # - as_recorded: the title as recorded
      # - vernacular: the vernacular title (default is nil)
      # - uniform_title: the uniform title (default is nil)
      # - uniform_title_vernacular: the vernacular uniform title (default is nil)
      #
      # Returns:
      # - A new Title object
      def initialize as_recorded:, vernacular: nil, uniform_title: nil, uniform_title_vernacular: nil
        @vernacular               = vernacular
        @uniform_title            = uniform_title
        @uniform_title_vernacular = uniform_title_vernacular
        super(as_recorded: as_recorded)
      end

      # Returns an array containing the title as recorded, vernacular title, uniform title, and vernacular uniform title.
      #
      # @return [Array] the title as an array
      def to_a
        # title_type is not included
        [as_recorded, vernacular, uniform_title, uniform_title_vernacular]
      end

      # Returns a hash representation of the title object.
      #
      # Keys are :as_recorded, :title_as_recorded_agr, :uniform_title_as_recorded, :uniform_title_as_recorded_agr
      #
      # @return [Hash] the title as a hash
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
