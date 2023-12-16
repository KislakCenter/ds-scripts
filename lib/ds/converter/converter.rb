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
  # 2. Selects a Mapper type based on the source data type
  # 3. Assembles the data need for mapping
  # 4. Maps each record to the data hash, assembling all the
  #    data hashes needed for the import CSV
  # 5. Returns the assembled hashes to the caller
  #
  module Converter
    class Converter
      include Enumerable

      attr_reader :manifest
      attr_reader :timestamp
      attr_reader :source_dir
      attr_reader :mapper_cache

      ##
      # @param [DS::CSV] manifest the Manifest instance
      def initialize manifest
        @manifest     = manifest
        @timestamp    = Time.now
        @source_dir   = manifest.source_dir
        @mapper_cache = DS::Util::Cache.new
      end

      ##
      # @yieldparam [Hash<String,String>] the import CSV hash of data
      #   for each record
      # @return [Array<Hash<String,String>>] the array of all import CSV
      #   hashes for the provided manifest
      def convert &block
        data = []
        each do |entry|
          mapper = find_or_create_mapper entry, timestamp
          hash   = mapper.map_record entry
          data << hash
          yield hash if block_given?
        end
        data
      end

      ##
      # @yieldparam [DS::Manifest::Entry] entry the manifest line item
      #   for each record
      def each &block
        manifest.each do |entry|
          yield entry
        end
      end

      def find_or_create_mapper entry, tstamp
        key = mapper_key entry
        return mapper_cache.get_item key if mapper_cache.include? key
        mapper = create_mapper entry, tstamp
        mapper_cache.add key, mapper
        mapper
      end

      def create_mapper entry, tstamp
        case entry.source_type
        when DS::Manifest::Constants::MARC_XML
          DS::Mapper::MarcMapper.new source_dir: source_dir, timestamp:  tstamp
        when DS::Manifest::Constants::TEI_XML
          DS::Mapper::OPennTEIMapper.new source_dir: source_dir, timestamp:  tstamp
        when DS::Manifest::Constants::DS_METS
          DS::Mapper::DSMetsMapper.new source_dir: source_dir, timestamp: tstamp
        else
          raise NotImplementedError {
            "Mapper not implemented for source type: '#{entry.source_type}'"
          }
        end
      end

      def source_file_path entry
        File.join source_dir, entry.filename
      end

      def mapper_key entry
        { source_type: entry.source_type, manifest_path: manifest.csv_path }
      end
    end # class BaseConverter
  end # module Converter
end # module DS