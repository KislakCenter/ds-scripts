# frozen_string_literal: true

module DS
  module Extractor
    class Place < BaseTerm
      def to_h
        super.to_h.merge({ place_as_recorded: as_recorded })
      end
    end
  end
end
