# frozen_string_literal: true

module DS
  module Manifest
    class SimpleXmlLookupValidator < BaseLookupValidator

      attr_accessor :namespaces

      def initialize source, namespaces = {}
        @namespaces = namespaces.present? ? namespaces : DS::Constants::XML_NAMESPACES
        super source
      end

      # Locates a record in the XML document based on the given source path, ID, and ID location.
      #
      #  +id_location+ should be a template XPath expression that
      #     returns one or more records, for example:
      #
      #     "//record[controlfield[@tag='001'] = 'ID_PLACEHOLDER']"
      #
      # The string 'ID_PLACEHOLDER' must be in the template.It will
      # be replaced with the ID of the record to locate.
      #
      # @param source_path [String] the path to the source file
      # @param lookup_value [String] the lookup value for the record; e.g, MMSID
      # @param lookup_value_location [String] the location of the
      #   lookup_value_location within the record; an XPath
      # @return [Array<Object>] an array of objects for each record
      def locate_record source_path, lookup_value, lookup_value_location
        locator = DS::Extractor::XmlRecordLocator.new namespaces: namespaces
        xml = source.load_source source_path
        locator.locate_record xml, lookup_value, lookup_value_location
      end

      def try_locate_record xml, xpath, namespaces: nil
        xml.xpath xpath, namespaces
      rescue Nokogiri::XML::XPath::SyntaxError => e
        raise unless e.message =~ /undefined namespace prefix/i
        []
      end
    end
  end
end
