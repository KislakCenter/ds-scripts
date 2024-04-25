# frozen_string_literal: true

module Recon
  class ReconBuilder
    attr_reader :source_type
    attr_reader :files
    attr_reader :out_dir

    SOURCE_TYPE_ENUMERATORS = {
      DS::Constants::DS_CSV => Recon::DsCsvEnumerator,
      DS::Constants::MARC_XML => Recon::MarcXmlEnumerator
    }

    SOURCE_TYPE_EXTRACTORS = {
      DS::Constants::MARC_XML => DS::MarcXml,
      DS::Constants::DS_CSV   => DS::DsCsv,
      DS::Constants::DS_METS  => DS::DsMetsXml,
      DS::Constants::TEI_XML  => DS::TeiXml
    }

    ReconType = Struct.new(
      'ReconType', :method_name, :item_type, :columns, :delimiter_map,
      keyword_init: true
    )

    RECON_TYPES = [
      ReconType.new(
        method_name: %i[extract_places],
        item_type: :places,
        columns: %w[authorized_label structured_value],
        delimiter_map: { '|' => ';'}
      ),
      ReconType.new(
        method_name:   :extract_materials,
        item_type:     :materials,
        columns:       %w[authorized_label structured_value],
        delimiter_map: { '|' => ';' }
      ),
      ReconType.new(
        method_name: %i[extract_authors extract_artists extract_scribes extract_former_owners],
        item_type: :names,
        columns: %w[instance_of authorized_label structured_value]
      ),
      ReconType.new(
        method_name: %i[extract_genres],
        item_type: :genres,
        columns: %w[authorized_label structured_value]
      ),
      ReconType.new(
        method_name: %i[extract_subjects],
        item_type: :subjects,
        columns: %w[authorized_label structured_value]
      ),
      ReconType.new(
        method_name: %i[extract_named_subjects],
        item_type: :'named-subjects',
        columns: %w[authorized_label structured_value],
        delimiter_map: { '|' => ';' }
      ),
      ReconType.new(
        method_name: %i[extract_titles],
        item_type: :titles,
        columns: %w[authorized_label]
      ),
      ReconType.new(
        method_name: %i[extract_languages],
        item_type: :languages,
        columns: %w[authorized_label structured_value]
      )
    ]

    def initialize source_type:, files:, out_dir:
      @source_type = source_type
      @files       = files
      @out_dir     = out_dir
    end

    def enumerator
      return @enumerator if @enumerator.present?
      klass = SOURCE_TYPE_ENUMERATORS[source_type]
      @enumerator = klass.new files
    end

    def extractor
      return @extractor if @extractor.present?
      @extractor = SOURCE_TYPE_EXTRACTORS[source_type]
    end

    ##
    # @note: +delimiter_map+: see {#build_recons}
    def extract_recons item_type
      items = Set.new
      recon_config = find_recon_type item_type

      enumerator.each do |record|
        [recon_config.method_name].flatten.each do |name|
          items += extractor.send(name.to_sym, record)
        end
      end
      recons = build_recons(
        items:         items,
        recon_type:    recon_config.item_type.to_s,
        columns:       recon_config.columns,
        delimiter_map: recon_config.delimiter_map
      )
      recons.sort
    end

    def find_recon_type name
      RECON_TYPES.find { |config| config.item_type == name.to_sym }
    end

    ##
    # Build an array of recon CSV rows; e.g.,
    #
    #       [
    #          ["Arabic", nil, "Arabic", "Q13955"],
    #          ["Farsi", nil, "Persian", "Q9168"],
    #          ["Latin", nil, "Latin", "Q397"]
    #       ]
    #
    # Note the +delimiter_map+ option. This is a hash of replacement
    # values to use when one delimiter should replace another. For
    # example, the source recon CSV may have a subfields divided by
    # pipes (+|+), when they should be separated by the standard
    # subfield delimiter, the semicolon (+;+).
    #
    # @todo: There's something off about the need to replace delmiters
    #   the source and output of the recon result are the recon CSV.
    #   There shouldn't be any need to make this conversion. Keeping
    #   the behavior for now to match the code being refactored.
    #
    # @param items [Array<DS::Extractor::BaseTerm>] the list of terms to process e.g, Language
    # @param recon_type [String] the recon set name; e.g., 'languages'
    # @param columns [Array<Symbol>] a list of recon columns to add to the term array; e.g., <tt>[:authorized_label, :structured_value]</tt>
    # @param delimiter_map [Hash<String,String>] a map of delimiters to replace; e.g., <tt>{ '|' => ';' }</tt>
    # @return [Array<Array<String>]> an array of arrays of +item.to_a+ plus recon columns; e.g., <tt>[['Arabic', 'ara', 'Arabic', 'Q13955']]</tt>
    def build_recons items:, recon_type:, columns: [], delimiter_map: {}
      items.map { |item|
        as_recorded = item.as_recorded
        row = item.to_a
        row += columns.map { |col|
          val = Recon.lookup(recon_type, value: as_recorded, column: col)
          fix_delimiters val, delimiter_map
        }
        row
      }
    end

    def fix_delimiters value, delimiter_map = {}
      return value if delimiter_map.blank?
      val = ''
      delimiter_map.each  { |old, new| val = value.gsub old, new }
      val
    end
  end
end
