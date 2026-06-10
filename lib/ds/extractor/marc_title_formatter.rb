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
      attr_accessor :datafield

      # Formats title strings
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted title string
      def format datafield
        datafield.xpath("subfield[@code='a' or @code='b']").map { |title|
          DS::Util.clean_string(title.text, terminator: '')
        }.join '; '
      end
    end
  end
end
