# frozen_string_literal: true
module DS
  module Extractor
    # The MarcTitleFormatter is responsible for formatting
    # a title string given a Marc datafield node. It concatenates
    # subfields a and b and then normalizes the string.
    # Subclasses can override #codes to change the
    # subfields that are used.
    class MarcTitleFormatter

      # Formats the title string given a datafield
      # node and concatenated string from the
      # subfield codes.
      #
      # @param [Nokogiri::XML::Node] datafield the +marc:datafield+ node
      # @return [String] a formatted title string
      def format datafield
        title = datafield.xpath(xpath).map(&:text).join ' '
        DS::Util.normalize_string(title)
      end

      # Concatenates a subfields string to be extracted from
      # a xpath node
      #
      # @return [String] joined text from subfields
      def xpath
        return "subfield" if codes.empty?
        code_string = codes.map { |code| "@code='#{code}'"}.join ' or '
        "subfield[#{code_string}]"
      end

      private

      # @return [Array] an array of subfield codes
      def codes
        %w[a b]
      end
    end
  end
end
