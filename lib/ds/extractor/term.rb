# frozen_string_literal: true

module DS
  module Extractor
    class Term < BaseTerm

      attr_accessor :vocab
      attr_accessor :source_authority_uri

      def initialize(
        as_recorded:,
        source_authority_uri: nil,
        vocab: nil
      )
        @source_authority_uri = source_authority_uri
        @vocab                = vocab
        super(as_recorded: as_recorded)
      end

      def to_a
        [as_recorded, vocab, source_authority_uri]
      end

      def to_h
        {
          as_recorded: as_recorded,
          source_authority_uri: source_authority_uri,
          vocab: vocab
        }
      end
    end
  end
end
