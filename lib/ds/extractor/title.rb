# frozen_string_literal: true

module DS
  module Extractor
    class Title < BaseTerm
      attr_accessor :vernacular

      # Initializes a new Title object.
      #
      # Parameters:
      # - as_recorded: the title as recorded
      # - vernacular: the vernacular title (default is nil)
      #
      # Returns:
      # - A new Title object
      def initialize as_recorded:, vernacular: nil
        super(as_recorded: as_recorded)
        @vernacular               = vernacular
      end

      # Returns an array containing the title as recorded and vernacular title
      #
      # @return [Array] the title as an array
      def to_a
        [as_recorded, vernacular]
      end

      # Returns a hash representation of the title object.
      #
      # Keys are :as_recorded, :title_as_recorded_agr
      #
      # @return [Hash] the title as a hash
      def to_h
        {
          title_as_recorded: as_recorded,
          title_as_recorded_agr: vernacular,
        }
      end
    end
  end
end
