# frozen_string_literal: true

module DS
  module Manifest
    ##
    # MARC ID validator subclasses {DS::Manifest::SimpleXmlIdValidator}
    # and implements the {DS::Manifest::BaseIdValidator#valid?} method
    # accommodating the different way that MARC records are retrieved
    class MarcIdValidator < SimpleXmlIdValidator

      # Locates the MARC record(s) for the given source path, ID, and
      # ID location.
      #
      # +id_location+ will be inserted into this XPath expression:
      #
      #    "//record[#{id_location} = '#{id}']"
      #
      # @param source_path [String] the path to the source file
      # @param id [String] the ID of the record
      # @param id_location [String] the location of the ID within the record
      # @return [Nokogiri::XML::NodeSet] an array of parsed MARC
      #   records for each record matching the given ID and ID
      #   location
      def locate_record source_path, id, id_location
        xml = find_or_open_source source_path
        xml.remove_namespaces!
        xpath = "//record[#{id_location} = '#{id}']"

        xml.xpath(xpath)
      end

    end
  end
end
