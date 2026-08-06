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
        arr = datafield.xpath("subfield[@code='t' or @code='p']").map { |title|
          DS::Util.clean_string(title.text, terminator: '')
        }
        first = arr.shift
        arr.empty? ? first : "#{first}: #{arr.join ' '}"
      end
    end
  end
end
