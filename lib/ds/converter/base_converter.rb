# frozen_string_literal: true

module DS
  ##
  # The DS Converter is responsible for generating the import
  # spreadsheet for a set of data. Its work is driven by a Manifest
  # CSV represented by a DS::Manifest::Manifest instance. Each row of
  # the CSV is represented by a DS::Manifest::Entry instance.
  #
  # The DS Converter does the following:
  #
  # 1. Reads each entry from the Manifest CSV
  # 2. Locates the source file named in the entry
  # 3. Selects a Mapper type based on the source data type
  # 4. Assembles the data need for mapping
  # 5. Maps each record to the data hash, assembling all the
  #    data hashes needed for the import CSV
  # 6. Returns the assembled hashes to the caller
  #
  module Converter
    class BaseConverter
      include Enumerable

      attr_reader :manifest
      attr_reader :timestamp
      attr_reader :source_dir

      ##
      # @param [DS::CSV] manifest the Manifest instance
      def initialize manifest
        @manifest  = manifest
        @timestamp = Time.now
        @source_dir = manifest.source_dir
      end

      ##
      # @yieldparam [Hash<String,String>] the import CSV hash of data
      #   for each record
      # @return [Array<Hash<String,String>>] the array of all import CSV
      #   hashes for the provided manifest
      def convert &block
        data = []
        each do |entry, record|
          mapper = get_mapper entry, record, timestamp
          hash   = mapper.map_record
          data << hash
          yield hash if block_given?
        end
        data
      end

      ##
      # @yieldparam [DS::Manifest::Entry] entry the manifest line item
      #   for each record
      # @yieldparam [Nokogiri::XML::Element] record the XML node for the
      #   yielded entry
      def each &block
        manifest.each do |entry|
          record = retrieve_record entry
          yield entry, record
        end
      end

      ##
      # @param [DS::Manifest::Entry] entry the manifest data for this
      #       record
      # TODO: move extract record to MarcMapper allow it to find the correct
      #   record based on entry
      def retrieve_record entry
        case entry.source_type
        when DS::Manifest::Constants::MARC_XML
          xml_string = File.open(source_file_path entry).read
          xml = Nokogiri::XML xml_string
          xml.remove_namespaces!
          xpath = "//record[./controlfield[@tag='001' and ./text() = '#{entry.institutional_id}']]"
          # TODO: use xml.at_xpath to get the first item
          xml.xpath(xpath).first
        when DS::Manifest::Constants::TEI_XML
          xml_string = File.open(source_file_path entry).read
          xml = Nokogiri::XML xml_string
          xml.remove_namespaces!
          xpath = "//TEI[./teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno/text() = '#{entry.call_number}']"
          xml.xpath(xpath).first
        else
          raise NotImplementedError,
                "Record extraction not implemented for source type #{entry.source_type}"
        end
      end

      def get_mapper entry, record, tstamp
        case entry.source_type
        when DS::Manifest::Constants::MARC_XML
          DS::Mapper::MarcMapper.new(
            manifest_entry: entry, record: record, timestamp: tstamp
          )
        when DS::Manifest::Constants::TEI_XML
          DS::Mapper::OPennTEIMapper.new(
            manifest_entry: entry, record: record, timestamp: tstamp
          )
        else
          raise NotImplementedError,
                "Mapper not implemented for source type: '#{entry.source_type}'"
        end
      end

      def source_file_path entry
        File.join source_dir, entry.filename
      end

    end # class BaseConverter
  end # module Converter
end # module DS