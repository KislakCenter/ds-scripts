# frozen_string_literal: true

# require_relative 'recon_config'
require_relative 'recon_type'

module Recon
  class ReconBuilder
    attr_reader :source_type
    attr_reader :files
    attr_reader :out_dir

    SOURCE_TYPE_ENUMERATORS = {
      DS::Constants::DS_CSV => Recon::DsCsvEnumerator,
      DS::Constants::MARC_XML => Recon::MarcXmlEnumerator,
      DS::Constants::TEI_XML => Recon::TeiXmlEnumerator,
      DS::Constants::DS_METS => Recon::DsMetsXmlEnumerator,
    }

    SOURCE_TYPE_EXTRACTORS = {
      DS::Constants::MARC_XML => DS::Extractor::MarcXml,
      DS::Constants::DS_CSV   => DS::Extractor::DsCsv,
      DS::Constants::DS_METS  => DS::Extractor::DsMetsXml,
      DS::Constants::TEI_XML  => DS::Extractor::TeiXml
    }

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
      @extractor ||= SOURCE_TYPE_EXTRACTORS[source_type]
    end

    def write_csv set_name
      recons = extract_recons set_name
      if recons.blank?
        STDERR.puts "WARNING: No recon values for #{set_name}"
        return
      end

      outfile = File.join out_dir, "#{set_name}.csv"
      CSV.open outfile, 'w+', headers: true do |csv|
        csv << recons.first.keys
        recons.each do |row|
          csv << row
        end
      end
      outfile
    end

    ##
    # @note: +delimiter_map+: see {#build_recons}
    def extract_recons set_name
      items = Set.new
      recon_config = Recon.find_recon_config set_name

      enumerator.each do |record|
        [recon_config.method_name].flatten.each do |name|
          next unless extractor.respond_to? name.to_sym
          items += extractor.send(name.to_sym, record)
        end
      end
      recons = build_recons(items: items, recon_type: recon_config.klass)

      recons.sort { |a,b|
        a.values.join.downcase <=> b.values.join.downcase
      }
    end

    def find_recon_type name
      Recon::RECON_TYPES.find { |config| config.set_name == name.to_s }
    end

    ##
    # Build an array of recon CSV rows; e.g.,
    #
    #         [
    #           { :language_as_recorded => "Arabic", :language_code => "", "authorized_label" => "Arabic", "structured_value" => "Q13955" },
    #           { :language_as_recorded => "Farsi", :language_code => "", "authorized_label" => "Persian", "structured_value" => "Q9168" },
    #           { :language_as_recorded => "Latin", :language_code => "", "authorized_label" => "Latin", "structured_value" => "Q397" }
    #         ]
    #
    # Note the +delimiter_map+ option. This is a hash of replacement
    # values to use when one delimiter should replace another. For
    # example, the source recon CSV may have a subfields divided by
    # pipes (+|+), when they should be separated by the standard
    # subfield delimiter, the semicolon (+;+).
    #
    # @todo: There's something off about the need to replace
    #   delimiters; the source and output of this recon data are the
    #   recon CSV. There shouldn't be any need to make this
    #   conversion. Keeping the behavior for now to match the code
    #   being refactored.
    #
    # @param items [Array<DS::Extractor::BaseTerm>] the list of terms to process e.g, Language
    # @param recon_type [Recon::ReconType] the recon type config struct
    # @return [Array<Hash<Symbol,String>>] an array of arrays of +item.to_h+ plus recon columns; e.g., <tt>[{ :language_as_recorded => "Arabic", :language_code => "", "authorized_label" => "Arabic", "structured_value" => "Q13955" }]</tt>
    def build_recons items:, recon_type:
      items.map { |item|
        as_recorded = item.as_recorded
        row = item.to_h
        recon_type.lookup_columns.each do |col|
          val = Recon.lookup(recon_type.set_name, value: as_recorded, column: col)
          row[col.to_sym] = fix_delimiters val, recon_type.delimiter_map
        end
        row
      }
    end

    def fix_delimiters value, delimiter_map = {}
      return value if delimiter_map.blank?
      val = ''
      delimiter_map.each  { |old, new| val = value.to_s.gsub old, new }
      val
    end
  end
end
