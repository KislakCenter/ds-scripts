# frozen_string_literal: true

module DS
  module Extractor

    class Subject < BaseTerm

      attr_accessor :subfield_codes
      attr_accessor :source_authority_uri
      attr_accessor :vocab

      # Initializes a new Subject instance with the provided parameters.
      #
      # @param as_recorded [String] The recorded data.
      # @param subfield_codes [String, nil] The subfield codes.
      # @param vocab [String, nil] The vocabulary.
      # @param source_authority_uri [String, nil] The source authority URI.
      # @return [void]
      def initialize(
        as_recorded:,
        subfield_codes: nil,
        vocab: nil,
        source_authority_uri: nil
      )

        @subfield_codes       = subfield_codes
        @vocab                = vocab
        @source_authority_uri = source_authority_uri

        super as_recorded: as_recorded
      end

      # Returns an array representation of the Subject instance.
      #
      #  Values are: [as_recorded, subfield_codes, vocab, source_authority_uri]
      #
      # @return [Array<String>] An array containing the recorded data, subfield codes, vocabulary, and source authority URI.
      def to_a
        [as_recorded, subfield_codes, vocab, source_authority_uri]
      end

      # Returns a hash representation of the Subject instance.
      #
      #  Keys are :as_recorded, :subfield_codes, :vocab, :source_authority_uri
      #
      # @return [Hash<Symbol,String>] A hash containing the recorded data, subfield codes, vocabulary, and source authority URI.
      def to_h
        {
          subject_as_recorded:  as_recorded,
          as_recorded:          as_recorded,
          subfield_codes:       subfield_codes,
          vocab:                vocab,
          source_authority_uri: source_authority_uri
        }
      end
    end
  end
end
