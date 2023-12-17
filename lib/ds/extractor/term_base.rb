# frozen_string_literal: true

module DS
  module Extractor
    class TermBase

      def to_a
        raise NotImplementedError
      end

      def to_h
        raise NotImplementedError
      end

    end
  end
end