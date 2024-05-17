# frozen_string_literal: true

module DS
  module Extractor
    class Genre < BaseTerm

      attr_accessor :vocab
      attr_accessor :source_authority_uri

      # Initializes a new Genre object.
      #
      # @param as_recorded [String] the recorded data
      # @param source_authority_uri [String, nil] the source authority URI (default is nil)
      # @param vocab [String, nil] the vocabulary (default is nil)
      # @return [void]
      def initialize(
        as_recorded:,
        source_authority_uri: nil,
        vocab: nil
      )
        @source_authority_uri = source_authority_uri
        @vocab                = vocab
        super(as_recorded: as_recorded)
      end

      # Returns an array containing the recorded data, vocabulary, and source authority URI.
      # @return [Array<String>]
      def to_a
        [as_recorded, vocab, source_authority_uri]
      end

      # Returns a hash representation of the Genre object.
      #
      # @return [Hash<Symbol,String>] a hash with keys +:as_recorded+, +:source_authority_uri+, and +:vocabulary+
      def to_h
        {
          as_recorded: as_recorded,
          source_authority_uri: source_authority_uri,
          vocabulary: vocab
        }
      end
    end
  end
end
