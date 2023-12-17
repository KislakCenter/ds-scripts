# frozen_string_literal: true

module DS
  module Extractor
    class Genre

      attr_accessor :as_recorded
      attr_accessor :vocab
      attr_accessor :source_authority_uri

      def initialize(
        as_recorded: nil,
        source_authority_uri: nil,
        vocab: nil
      )
        @as_recorded          = as_recorded
        @source_authority_uri = source_authority_uri
        @vocab                = vocab
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