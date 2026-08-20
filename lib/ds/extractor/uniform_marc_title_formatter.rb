# frozen_string_literal: true
module DS
  module Extractor
    ##
    # The UniformMarcTitleFormatter is responsible for formatting
    # a title string given a Marc datafield. It works for
    # 130, 240 and 730 title fields.
    #
    # Parameters:
    # - datafield: a Marc xml datafield node
    #
    # Returns:
    # - A formatted Title string
    class UniformMarcTitleFormatter
      # Formats uniform title strings
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted uniform title string
      def format datafield
        title = datafield.xpath("subfield[@code='a' or @code='p']").map(&:text).join ' '
        DS::Util.normalize_string(title)
      end
    end
  end
end
