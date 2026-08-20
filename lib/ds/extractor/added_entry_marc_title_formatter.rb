# frozen_string_literal: true
module DS
  module Extractor
    ##
    # The AddedEntryMarcTitleFormatter is responsible for formatting
    # a title string given a Marc datafield. It works for
    # 700 and 710 title fields.
    #
    # Parameters:
    # - datafield: a Marc xml datafield node
    #
    # Returns:
    # - A formatted Title string
    class AddedEntryMarcTitleFormatter
      # Formats uniform title strings
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted uniform title string
      def format datafield
        title = datafield.xpath("subfield[@code='t' or @code='p']").map(&:text).join ' '
        DS::Util.normalize_string(title)
      end
    end
  end
end
