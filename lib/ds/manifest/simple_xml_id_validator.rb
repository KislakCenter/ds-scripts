# frozen_string_literal: true

module DS
  module Manifest
    class SimpleXmlIdValidator < BaseIdValidator

      attr_accessor :namespaces

      def initialize namespaces = {}
        @namespaces = namespaces.present? ? namespaces : DS::Constants::XML_NAMESPACES
        super()
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
      # @param source_path [String] the path to the XML source file
      # @param id [String] the ID of the record to locate
      # @param id_location [String] the XPath expression to locate the record
      # @return [Nokogiri::XML::NodeSet] the located record(s)
      def locate_record source_path, id, id_location
        locator = DS::Extractor::XmlRecordLocator.new namespaces: namespaces
        source = find_or_open_source source_path
        locator.locate_record source, id, id_location
        # xml = find_or_open_source source_path
        # formatted_location = id_location.gsub('ID_PLACEHOLDER', id)
        #
        # # try with namespaces
        # record = try_locate_record xml, formatted_location, namespaces: namespaces
        # return record if record.present?
        #
        # # try without providing namespaces
        # record = try_locate_record xml, formatted_location
        # return record if record.present?
        #
        # # strip namespaces and try one last time
        # xml.remove_namespaces!
        # try_locate_record xml, formatted_location
      end

      def try_locate_record xml, xpath, namespaces: nil
        xml.xpath xpath, namespaces
      rescue Nokogiri::XML::XPath::SyntaxError => e
        raise unless e.message =~ /undefined namespace prefix/i
        []
      end

      # Opens the XML source file at the given path and returns an XML document without namespaces.
      #
      # @param source_path [String] the path to the source file
      # @return [Nokogiri::XML::Document] the XML document without namespaces
      def open_source source_path
        File.open(source_path) { |f| Nokogiri::XML(f) }
      end
    end
  end
end
