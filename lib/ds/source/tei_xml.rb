# frozen_string_literal: true

module DS
  module Source
    class TeiXML < BaseSource

      TYPE = DS::Constants::TEI_XML

      # Opens a TEI XML file at the given path and returns it as a Nokogiri::XML object.
      #
      # NB: Namespaces are stripped from the document.
      #
      # @param source_file_path [String] the path to the source file
      # @return [Nokogiri::XML::Document] the contents of the source file as a Nokogiri::XML object
      def open_source source_file_path
        xml = File.open(source_file_path) { |f| Nokogiri::XML f }
        xml.remove_namespaces!
        xml
      end
    end
  end
end
