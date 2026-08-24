# frozen_string_literal: true
module DS
  module Extractor
    ##
    # The UniformMarcTitleFormatter inherits from the
    # MarcTitleFormatter and is responsible for formatting
    # a title string given a Marc datafield. It works for
    # 130, 240 and 730 title fields.
    #
    # Parameters:
    # - datafield: a Marc xml datafield node
    #
    # Returns:
    # - A formatted Uniform Title string
    class UniformMarcTitleFormatter < MarcTitleFormatter

      private
      def codes
        %w[a p]
      end
    end
  end
end
