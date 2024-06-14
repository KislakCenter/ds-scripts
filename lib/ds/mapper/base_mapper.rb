# frozen_string_literal: true

module DS
  module Mapper
    # DS::Mapper::BaseMapper abstract Mapper class. Implementing classes
    # map DS sources records to CSV rows.
    #
    # Implementing classes must implement:
    #
    # - `#extract_record`
    # - `#map_record`
    #
    class BaseMapper
      attr_reader :timestamp
      attr_reader :source_dir
      attr_reader :source
      attr_reader :recon_builder

      PLACES_COLUMN_MAP = {
        production_place_as_recorded: :place_as_recorded,
        production_place:             :structured_value,
        production_place_label:       :authorized_label,
        production_place_ds_qid:      :ds_qid
      }

      TITLES_COLUMN_MAP = {
        title_as_recorded:         :title_as_recorded,
        title_as_recorded_agr:     :title_as_recorded_agr,
        uniform_title_as_recorded: :uniform_title_as_recorded,
        uniform_title_agr:         :uniform_title_as_recorded_agr,
        standard_title:            :authorized_label,
        standard_title_ds_qid:     :ds_qid
      }

      GENRES_COLUMN_MAP = {
        genre_as_recorded: :genre_as_recorded,
        genre:             :structured_value,
        genre_label:       :authorized_label,
        genre_vocabulary:  :vocabulary,
        genre_ds_qid:      :ds_qid
      }

      SUBJECTS_COLUMN_MAP = {
        subject_as_recorded: :subject_as_recorded,
        subject:             :structured_value,
        subject_label:       :authorized_label,
        subject_ds_qid:      :ds_qid,
      }

      AUTHORS_COLUMN_MAP = {
        author:                 :empty_value,
        author_as_recorded:     :name_as_recorded,
        author_as_recorded_agr: :name_agr,
        author_wikidata:        :structured_value,
        author_instance_of:     :instance_of,
        author_label:           :authorized_label,
        author_ds_qid:          :ds_qid

      }

      ARTISTS_COLUMN_MAP = {
        artist:                 :empty_value,
        artist_as_recorded:     :name_as_recorded,
        artist_as_recorded_agr: :name_agr,
        artist_wikidata:        :structured_value,
        artist_instance_of:     :instance_of,
        artist_label:           :authorized_label,
        artist_ds_qid:          :ds_qid
      }

      SCRIBES_COLUMN_MAP = {
        scribe:                 :empty_value,
        scribe_as_recorded:     :name_as_recorded,
        scribe_as_recorded_agr: :name_agr,
        scribe_wikidata:        :structured_value,
        scribe_instance_of:     :instance_of,
        scribe_label:           :authorized_label,
        scribe_ds_qid:          :ds_qid
      }

      ASSOCIATED_AGENT_COLUMN_MAP = {
        associated_agent:                 :empty_value,
        associated_agent_as_recorded:     :name_as_recorded,
        associated_agent_as_recorded_agr: :name_agr,
        associated_agent_wikidata:        :structured_value,
        associated_agent_instance_of:     :instance_of,
        associated_agent_label:           :authorized_label,
        associated_agent_ds_qid:          :ds_qid
      }

      LANGUAGE_COLUMN_MAP = {
        language_as_recorded: :language_as_recorded,
        language:             :structured_value,
        language_label:       :authorized_label,
        language_ds_qid:      :ds_qid
      }

      FORMER_OWNER_COLUMN_MAP = {
        former_owner:                 :empty_value,
        former_owner_as_recorded:     :name_as_recorded,
        former_owner_as_recorded_agr: :name_agr,
        former_owner_wikidata:        :structured_value,
        former_owner_instance_of:     :instance_of,
        former_owner_label:           :authorized_label,
        former_owner_ds_qid:          :ds_qid
      }

      MATERIAL_COLUMN_MAP = {
        material_as_recorded: :material_as_recorded,
        material:             :structured_value,
        material_label:       :authorized_label,
        material_ds_qid:      :ds_qid
      }

      # Maps recon type to column map
      RECON_TYPE_COLUMN_MAP = {
        Recon::Type::Places           => PLACES_COLUMN_MAP,
        Recon::Type::Titles           => TITLES_COLUMN_MAP,
        Recon::Type::Genres           => GENRES_COLUMN_MAP,
        Recon::Type::AllSubjects      => SUBJECTS_COLUMN_MAP,
        Recon::Type::Authors          => AUTHORS_COLUMN_MAP,
        Recon::Type::Artists          => ARTISTS_COLUMN_MAP,
        Recon::Type::Scribes          => SCRIBES_COLUMN_MAP,
        Recon::Type::AssociatedAgents => ASSOCIATED_AGENT_COLUMN_MAP,
        Recon::Type::Languages        => LANGUAGE_COLUMN_MAP,
        Recon::Type::FormerOwners     => FORMER_OWNER_COLUMN_MAP,
        Recon::Type::Materials        => MATERIAL_COLUMN_MAP,
      }.freeze

      # Initializes a new instance of the class.
      #
      # @param source_dir [String] the directory where the source files are located
      # @param timestamp [Time] the timestamp of the source files
      # @param source [DS::Source::BaseSource] the source object
      # @return [void]
      def initialize source_dir:, timestamp:, source:
        @recon_builder = Recon::ReconBuilder.new source_type: source.source_type, files: [], out_dir: []
        @source        = source
        @source_dir    = source_dir
        @timestamp     = timestamp
      end

      def to_s # :nodoc:
        "#{self.class.name}: source_dir: #{source_dir}, timestamp: #{timestamp}, source: #{source}"
      end

      # Extracts a record from the source for the given manifest entry.
      #
      # @param [DS::Manifest::Entry] entry the entry representing one row in a manifest
      # @return [Object] the extracted record; e.g., a Nokogiri::XML::Node or CSV::Row
      # @raise [NotImplementedError] if the method is not implemented in a subclass
      def extract_record entry
        raise NotImplementedError
      end

      # Maps a source record for the given manifest entry.
      #
      # @param [DS::Manifest::Entry] entry the entry representing one row in a manifest
      # @return [Hash<Symbol, String>] the mapped record
      # @raise [NotImplementedError] if the method is not implemented in a subclass
      def map_record entry
        raise NotImplementedError
      end

      # Builds term strings based on the given recons and column mapping.
      #
      #
      # @example
      #  recons = [
      #      { as_recorded: 'Brown, Jamie', authorized_label: 'Jamie Brown' },
      #      { as_recorded: 'Hendrix, Morgan', authorized_label: 'Morgan Hendrix' }
      #  ]
      #  column_map = { author_as_recorded: :as_recorded, author_label: :authorized_label }
      #  build_term_strings(recons, column_map)
      #  # => { 'author_as_recorded' => 'Brown, Jamie| Hendrix, Morgan', :author_label => 'Jamie Brown|Morgan Hendrix', 'author_label' => 'Jamie Brown|Morgan Hendrix' }
      #
      # @param [Array<Hash>] recons the recons to build term strings from
      # @param [Hash] column_map a mapping of import CSV columns to recon keys
      # @return [Hash] a hash with import CSV columns as keys and corresponding term strings as values
      def build_term_strings recons, column_map
        column_map.inject({}) do |hash, (import_csv_col, recon_key)|
          hash[import_csv_col] = build_term_string recons, recon_key
          hash
        end
      end

      # Creates an import CSV hash for the given record for all recon
      # term types, using the given extractor. The extractor is one
      # of
      #
      #   DS::Extractor::MarcXml
      #   DS::Extractor::TeiXml
      #   DS::Extractor::DsCsvExtractor
      #   DS::Extractor::DsMetsXml
      #
      # The following recon term types are mapped for all
      # records/extractors:
      #
      #   Recon::Type::Places
      #   Recon::Type::Titles
      #   Recon::Type::Genres
      #   Recon::Type::Subjects
      #   Recon::Type::Authors
      #   Recon::Type::Artists
      #   Recon::Type::Scribes
      #   Recon::Type::AssociatedAgents
      #   Recon::Type::Languages
      #   Recon::Type::FormerOwners
      #   Recon::Type::Materials
      #
      # Column mappings are defined in DS::Mapper::RECON_TYPE_COLUMN_MAP
      #
      # @param [DS::Extractor::MarcXml, DS::Extractor::TeiXml, DS::Extractor::DsCsvExtractor, DS::Extractor::DsMetsXml] extractor the extractor object
      # @param [Nokogiri::XML::Node, CSV::Row] record the record to extract terms from
      # @return [Hash<Symbol, String>] a hash of terms mapped to import CSV columns
      def build_term_maps extractor, record
        RECON_TYPE_COLUMN_MAP.inject({}) { |hash, (recon_type, column_map)|
          terms = recon_type.method_name.flat_map { |method| extractor.send(method, record) }
          hash.update map_terms terms, recon_type, column_map
        }
      end

      # Builds a term string by concatenating the values of the given reconstructions
      # corresponding to the specified recon key, separated by '|'.
      #
      # @example
      #   recons = [
      #       { as_recorded: 'Brown, Jamie', authorized_label: 'Jamie Brown' },
      #       { as_recorded: 'Hendrix, Morgan', authorized_label: 'Morgan Hendrix' }
      #   ]
      #   build_term_string(recons, :as_recorded) # => 'Brown, Jamie|Hendrix, Morgan'
      #
      # @param recons [Array<Hash>] The array of recons hashes
      # @param recon_key [String, Symbol] The key used to access the values in each recon hash
      # @return [String] The concatenated term string.
      def build_term_string recons, recon_key
        recons.map { |recon| recon[recon_key.to_sym] }.join('|')
      end

      # Maps the given terms using the given recon type and column mapping.
      #
      # @param terms [Array<DS::Extractor::BaseTerm>] an array of terms to map
      # @param recon_type [Recon::Type::ReconType] a recon type configuration
      # @param column_map [Hash] a mapping of import CSV columns to recon keys
      # @return [Hash<Symbol,String>] an hash of mapped terms; e.g., { :author_as_recorded => 'Brown, Jamie|Hendrix, Morgan', :author_label => 'Jamie Brown|Morgan Hendrix', ... } for an array of mapped terms
      def map_terms terms, recon_type, column_map
        recons = recon_builder.build_all_recons terms, recon_type
        term_strings = build_term_strings recons, column_map
        term_strings
      end
    end
  end
end
