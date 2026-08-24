# frozen_string_literal: true
module DS
  module Extractor
    ##
    # The AddedEntryMarcTitleFormatter inherits from the
    # MarcTitleFormatter and is responsible for formatting
    # a title string given a Marc datafield. It works for
    # 700 and 710 title fields.
    #
    # Parameters:
    # - datafield: a Marc xml datafield node
    #
    # Returns:
    # - A formatted Added Entry Title string
    class AddedEntryMarcTitleFormatter < MarcTitleFormatter

      private
      def codes
        %w[t p]
      end
    end
  end
end
