# frozen_string_literal: true
module DS
  module Extractor
    class AddedEntryMarcTitleFormatter < MarcTitleFormatter
      # The AddedEntryMarcTitleFormatter has the same
      # behavior as MarcTitleFormatter. It overrides #codes
      # and concatenates subfields t and p.
      private
      # @return [Array] an array of subfield codes
      def codes
        %w[t p]
      end
    end
  end
end
