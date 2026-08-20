# frozen_string_literal: true
module DS
  module Extractor
    ##
    # The MarcTitleFormatter is responsible for formatting
    # a title string given a Marc datafield. It works for
    # 245 and 246 title fields.
    # Parameters:
    # - datafield: a Marc xml datafield node
    #
    # Returns:
    # - A formatted Title string
    class MarcTitleFormatter
      # Formats title strings
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted title string
      def format datafield
        title = datafield.xpath("subfield[@code='a' or @code='b']").map(&:text).join ' '
        DS::Util.normalize_string(title)
      end
    end
  end
end
