# frozen_string_literal: true
module DS
  module Extractor
    # The UniformMarcTitleFormatter has the same
    # behavior as MarcTitleFormatter. It overrides #codes
    # and concatenates subfields a and p.
    class UniformMarcTitleFormatter < MarcTitleFormatter

      private
      # @return [Array] an array of subfield codes
      def codes
        %w[a p]
      end
    end
  end
end
