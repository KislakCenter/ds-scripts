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
        DS::Util.normalize_string(xpath datafield)
      end

      private
      # @return [Array] an array of subfield codes
      def codes
        %w[a b]
      end

      # Extracts subfields from an xpath node and joins them as a string
      #
      # @return [String] joined text from subfields
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      def xpath datafield
        datafield.xpath("subfield[@code='#{codes[0]}' or @code='#{codes[1]}']").map(&:text).join ' '
      end
    end
  end
end
