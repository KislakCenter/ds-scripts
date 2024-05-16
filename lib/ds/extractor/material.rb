# frozen_string_literal: true

module DS
  module Extractor

    class Material < BaseTerm

      def to_h
        {
          as_recorded: as_recorded
        }
      end
    end
  end
end
