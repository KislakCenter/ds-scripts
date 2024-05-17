# frozen_string_literal: true

module DS
  module Extractor
    class Name < BaseTerm
      attr_accessor :role
      attr_accessor :vernacular
      attr_accessor :ref

      # Initializes a Name object with the provided parameters.
      #
      # Parameters:
      # @param as_recorded [String] the recorded name
      # @param role [String, NilClass] the role associated with the name
      # @param vernacular [String, NilClass] the vernacular name
      # @param ref [String, NilClass] the source authority URI
      # @return void
      def initialize as_recorded:, role: nil, vernacular: nil, ref: nil
        @role        = role
        @vernacular  = vernacular
        @ref         = ref
        super(as_recorded: as_recorded)
      end

      # Returns an array representation of the name.
      #
      #   [as_recorded, role, vernacular, ref]
      #
      # @return [Array] the name as an array
      def to_a
        [as_recorded, role, vernacular, ref]
      end

      # Returns a hash representation of the name object.
      #
      # Keys are :as_recorded, :role, :name_agr, :source_authority_uri
      #
      # @return [Hash] the name as a hash
      def to_h
        {
          as_recorded: as_recorded,
          role: role,
          name_agr: vernacular,
          source_authority_uri: ref
        }
      end
    end
  end
end
