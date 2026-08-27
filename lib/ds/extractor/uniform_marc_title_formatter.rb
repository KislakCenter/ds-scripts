# frozen_string_literal: true
module DS
  module Extractor
    class UniformMarcTitleFormatter < MarcTitleFormatter
      # The UniformMarcTitleFormatter has the same
      # behavior as MarcTitleFormatter. It overrides #codes
      # and concatenates subfields a and p.
      private
      # @return [Array] an array of subfield codes
      def codes
        %w[a p]
      end
    end
  end
end
