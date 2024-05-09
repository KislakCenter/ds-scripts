# frozen_string_literal: true

module DS
  module Extractor

    class Subject < BaseTerm

      attr_accessor :subfield_codes
      attr_accessor :source_authority_uri
      attr_accessor :vocab

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

      def to_a
        [as_recorded, subfield_codes, vocab, source_authority_uri]
      end

      def to_h
        {
          subject_as_recorded:          as_recorded,
          subfield_codes:       subfield_codes,
          vocab:                vocab,
          source_authority_uri: source_authority_uri
        }
      end
    end
  end
end
