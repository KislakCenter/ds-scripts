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
      # Formats title strings using normalization
      #
      # @return [String] a formatted title string
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      def format datafield
        title = datafield.xpath(xpath).map(&:text).join ' '
        DS::Util.normalize_string(title)
      end

      # @return [Array] an array of subfield codes
      def codes
        %w[a b]
      end

      # Creates a subfields string to be extracted from an xpath node
      #
      # @return [String] joined text from subfields
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      def xpath
        return "subfield" if codes.empty?
        "subfield[" +
          codes.map { |code| "@code='#{code}'" }.join(' or ') + "]"
      end
    end
  end
end
