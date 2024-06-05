# frozen_string_literal: true

module DS
  module Source
    class MarcXML < BaseSource

      # Opens a MARC XML source file at the given path and returns a Nokogiri::XML object representing the record.
      #
      # NB: Namespaces are stripped from the document.
      #
      # @param source_file_path [String] the path to the source file
      # @return [Nokogiri::XML::Document] the MARC XML record
      def open_source source_file_path
        xml = File.open(source_file_path) { |f| Nokogiri::XML f }
        xml.remove_namespaces!
        xml
      end
    end
  end
end
