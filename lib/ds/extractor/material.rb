# frozen_string_literal: true

module DS
  module Extractor

    class Material < BaseTerm

      def to_h
        {
          material_as_recorded: as_recorded
        }
      end
    end
  end
end
