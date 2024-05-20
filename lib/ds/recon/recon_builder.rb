# frozen_string_literal: true

# require_relative 'recon_config'
require_relative 'recon_type'

module Recon

  ##
  # A class to build recon CSV rows from DS data sources.#

  class ReconBuilder
    attr_reader :source_type
    attr_reader :files
    attr_reader :out_dir

    # A hash mapping DS data source types to their corresponding enumerator classes
    #
    # Keys:
    # - DS::Constants::DS_CSV
    # - DS::Constants::MARC_XML
    # - DS::Constants::TEI_XML
    # - DS::Constants::DS_METS
    #
    # Values:
    # - Recon::DsCsvEnumerator
    # - Recon::MarcXmlEnumerator
    # - Recon::TeiXmlEnumerator
    # - Recon::DsMetsXmlEnumerator
    SOURCE_TYPE_ENUMERATORS = {
      DS::Constants::DS_CSV => Recon::DsCsvEnumerator,
      DS::Constants::MARC_XML => Recon::MarcXmlEnumerator,
      DS::Constants::TEI_XML => Recon::TeiXmlEnumerator,
      DS::Constants::DS_METS => Recon::DsMetsXmlEnumerator,
    }

    # A hash mapping DS data source types to their corresponding extractor classes
    #
    # Keys:
    # - DS::Constants::DS_CSV
    # - DS::Constants::MARC_XML
    # - DS::Constants::TEI_XML
    # - DS::Constants::DS_METS
    #
    # Values:
    # - DS::Extractor::DsCsv
    # - DS::Extractor::MarcXml
    # - DS::Extractor::TeiXml
    # - DS::Extractor::DsMetsXml
    SOURCE_TYPE_EXTRACTORS = {
      DS::Constants::MARC_XML => DS::Extractor::MarcXml,
      DS::Constants::DS_CSV   => DS::Extractor::DsCsv,
      DS::Constants::DS_METS  => DS::Extractor::DsMetsXml,
      DS::Constants::TEI_XML  => DS::Extractor::TeiXml
    }

    # @param [Symbol] source_type a valid DS data source type; e.g., DS::Constants::MARC_XML
    # @param [Array] files an array of source file paths;e.g., +marc1.xml+, +marc2.xml+, etc.
    # @param [String] out_dir a path to an output directory
    def initialize source_type:, files:, out_dir:
      @source_type = source_type
      @files       = files
      @out_dir     = out_dir
    end

    # @return [Recon::SourceEnumerator] an source enumerator type; e.g., Recon::MarcXmlEnumerator
    def enumerator
      return @enumerator if @enumerator.present?
      klass = SOURCE_TYPE_ENUMERATORS[source_type]
      @enumerator = klass.new files
    end

    # @return [DS::Extractor::MarcXml,DS::Extractor::DsCsv,DS::Extractor::DsMetsXml,DS::Extractor::TeiXml] an extractor type; e.g., DS::Extractor::MarcXml
    def extractor
      @extractor ||= SOURCE_TYPE_EXTRACTORS[source_type]
    end

    ##
    # For each extracted term in of the given set type (like :places)
    # yield the corresponding recon CSV row.
    #
    # Example:
    #
    #     # for a ReconBuilder for set of TEI files
    #     CSV headers: true do |csv|
    #       csv << Recon::Places.csv_headers
    #       recon_builder.each_recon(:places) do |recon|
    #         csv << recon
    #       end
    #     end
    #
    # @param [Symbol] set_name a recon set name, like :places
    # @yield [Hash<Symbol, String>] a block that yields recon rows
    def each_recon set_name, &block
      items = Set.new
      recon_config = Recon.find_recon_type set_name

      enumerator.each do |record|
        [recon_config.method_name].flatten.each do |name|
          next unless extractor.respond_to? name.to_sym
          extractor.send(name.to_sym, record).each do |item|
            unless items.include? item
              items << item
              yield build_recon recon_type: recon_config, item: item
            end
          end
        end
      end
    end

    # Find a recon type configuration by name
    #
    # @param [String] name the name of the recon type to find
    # @return [Recon::ReconType, nil] the recon type configuration if found, nil otherwise
    def find_recon_type name
      Recon::RECON_TYPES.find { |config| config.set_name == name.to_s }
    end

    # A function that replaces delimiters in a value based on a given
    # delimiter map.
    #
    # @param value [String] the value to be processed
    # @param delimiter_map [Hash] a hash containing the old and new
    #   delimiters, e.g., for <tt>{ "|" => ";" }</tt> all +|+s will be
    #   replaced with +;+s
    # @return [String] the processed value with delimiters replaced
    def fix_delimiters value, delimiter_map = {}
      return value if delimiter_map.blank?
      val = ''
      delimiter_map.each  { |old, new| val = value.to_s.gsub old, new }
      val
    end

    private
    # Build a single recon CSV row; e.g.,
    #
    #    { :language_as_recorded => "Arabic",
    #      :language_code => "",
    #      :authorized_label => "Arabic",
    #      :structured_value => "Q13955" }
    #
    # @param [DS::Extractor::BaseTerm] item a term like a DS::Extractor::Place
    # @param [Recon::ReconType] recon_type a recon type configuration like Recon::Places
    # @return [Hash<Symbol,String>] a recon CSV row
    def build_recon item:, recon_type:
      as_recorded = item.as_recorded
      recon_hash = item.to_h
      recon_type.lookup_columns.each do |col|
        val = Recon.lookup(recon_type.set_name, value: as_recorded, column: col)
        recon_hash[col.to_sym] = fix_delimiters val, recon_type.delimiter_map
      end
      prep_row recon_hash: recon_hash, recon_type: recon_type
    end

    ##
    # Transform the recon hash
    #
    # Currently, we just replace the +as_recorded+ header with the type-specific
    # +ReconType#as_recorded_column+, e.g., +language_as_recorded+
    #
    #
    # @param recon_hash [Hash<Symbol,Object>] a hash of the CSV row
    # @param recon_type [Recon::ReconType] a ReconType like, ReconPlaces
    # @return [Hash<Symbol,Object>]
    def prep_row recon_hash:, recon_type:
      row = recon_hash.dup
      ar_value = row.delete :as_recorded
      row[recon_type.as_recorded_column] = ar_value
      row
    end

  end
end
