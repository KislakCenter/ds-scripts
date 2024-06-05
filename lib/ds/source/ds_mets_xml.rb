# frozen_string_literal: true

module DS
  module Source
    class DSMetsXML < BaseSource

      # Opens a METS XML file at the given path and returns it as a Nokogiri::XML object.
      #
      # Namespaces are *not* removed from the document.
      #
      # @param source_file_path [String] the path to the source file
      # @return [Nokogiri::XML::Document] the contents of the source file as a Nokogiri::XML object
      def open_source source_file_path
        File.open(source_file_path) { |f| Nokogiri::XML f }
      end
    end
  end
end
