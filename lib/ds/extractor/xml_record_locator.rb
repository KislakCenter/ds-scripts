# frozen_string_literal: true

module DS
  module Extractor
    class XmlRecordLocator < DS::Extractor::BaseRecordLocator

      attr_accessor :namespaces

      def initialize namespaces: DS::Constants::XML_NAMESPACES
        @namespaces = namespaces
        super()
      end

      def locate_record xml, id, id_location
        xpath = id_location.gsub(/ID_PLACEHOLDER/, id)
        # try with namespaces
        record = try_locate_record xml, xpath, namespaces: namespaces
        return record if record.present?

        # try without providing namespaces
        record = try_locate_record xml, xpath
        return record if record.present?

        # strip namespaces and try one last time
        xml.remove_namespaces!
        try_locate_record xml, xpath
      end

      def try_locate_record xml, xpath, namespaces: nil
        xml.xpath xpath, namespaces
      rescue Nokogiri::XML::XPath::SyntaxError => e
        add_error e.message
        raise unless e.message =~ /undefined namespace prefix/i
        []
      end
    end
  end
end
