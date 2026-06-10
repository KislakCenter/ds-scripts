# frozen_string_literal: true
module DS
  module Extractor
    class UniformMarcTitleFormatter
      ##
      # The UniformMarcTitleFormatter is responsible for formatting
      # a title string given a Marc datafield. It works for
      # 130 and 240 title fields.
      #
      # Parameters:
      # - datafield: a Marc xml datafield node
      #
      # Returns:
      # - A formatted Title string
      attr_accessor :datafield

      # Formats uniform title strings
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted uniform title string
      def format datafield
        arr = datafield.xpath("subfield[@code='a' or @code='p']").map { |title|
          DS::Util.clean_string(title.text, terminator: '')
        }
        first = arr.shift
        arr.empty? ? first : "#{first}: #{arr.join ' '}"
      end
    end
  end
end
