# frozen_string_literal: true
module DS
  module Extractor
    # The AddedEntryMarcTitleFormatter has the same
    # behavior as MarcTitleFormatter. It overrides #codes
    # and concatenates subfields t and p.
    class AddedEntryMarcTitleFormatter < MarcTitleFormatter

      private
      # @return [Array] an array of subfield codes
      def codes
        %w[t p]
      end
    end
  end
end
