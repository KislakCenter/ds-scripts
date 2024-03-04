require 'csv'

module DS
  module DSCSV
    COLUMN_MAPPINGS = {
      dsid:                               "DS ID",
      holding_institution_as_recorded:    "Holding Institution",
      source_type:                        "Source Type",
      cataloging_convention:              "Cataloging Convention",
      holding_institution_id_number:      "Holding Institution Identifier",
      holding_institution_shelfmark:      "Shelfmark",
      fragment_num_disambiguator:         "Fragment Number or Disambiguator",
      link_to_holding_institution_record: "Link to Institutional Record",
      link_to_iiif_manifest:              "IIIF Manifest",
      production_place_as_recorded:       "Production Place(s)",
      production_date_as_recorded:        "Date Description",
      production_date_start:              "Production Date START",
      production_date_end:                "Production Date END",
      dated:                              "Dated",
      uniform_title_as_recorded:          "Uniform Title(s)",
      uniform_title_agr:                  "Uniform Title(s) - Original Script",
      title_as_recorded:                  "Title(s)",
      title_as_recorded_agr:              "Title(s) - Original Script",
      genre_as_recorded:                  "Genre/Form",
      subject_as_recorded:                [
                                            "Named Subject(s)",
                                            "Subject(s)",
                                          ],
      author_as_recorded:                 "Author Name(s)",
      artist_as_recorded:                 "Artist Name(s)",
      scribe_as_recorded:                 "Scribe Name(s)",
      former_owner_as_recorded:           "Former Owner Name(s)",
      language_as_recorded:               "Language(s)",
      material_as_recorded:               "Materials Description",
      extent:                             "Extent",
      dimensions:                         "Dimensions",
      note:                               [
                                            "Layout",
                                            "Script",
                                            "Decoration",
                                            "Binding",
                                            "Physical Description Miscellaneous",
                                            "Provenance Notes",
                                            "Note 1",
                                            "Note 2"
                                          ],
      acknowledgements:                   "Acknowledgements",
      data_source_modified:               "Date Updated by Contributor",
    }.freeze

    module ClassMethods

      def extract_physical_description record
        extent = extract_extent record
        material = extract_material_as_recorded record
        dimensions = extract_dimensions record
        desc = [ extent, material, dimensions ].flatten
        return unless desc.any?(&:present?)
        "Extent: #{desc.join '; '}"
      end

      # def extract_dimensions_description record
      #   textblock = extract_text_block_dimensions record
      #   bound = extract_bound_dimensions record
      #
      #   return textblock.first if bound.blank?
      #   return bound.first if textblock.blank?
      #
      #   "#{textblock.first} bound to #{bound.first}"
      # end

      def extract_production_date record, separator: '-'
        start_date = extract_production_date_start record
        end_date   = extract_production_date_end record
        [start_date,end_date].select(&:present?).join separator
      end

      def method_missing name, *args, **kwargs
        string_name = name.to_s
        return super unless string_name =~ /^extract_\w+/
        property = string_name.split(/_/, 2).last
        unless COLUMN_MAPPINGS.include? property.to_sym
          raise "Unknown property #{property}"
        end

        columns = [COLUMN_MAPPINGS[property.to_sym]].flatten
        record = args.first
        columns.filter_map { |header|
          record[header]
        }.flatten.flat_map { |value| value.split '|'  }
      end

      def extract_note record
        COLUMN_MAPPINGS[:note].filter_map { |header|
          vals = record[header].to_s.split '|'
          next unless vals
          case header
          when /^(Note|Physical description)/i
            vals
          when /^Provenance/
            vals.map { |v| "Provenance: #{v}" }
          else
            vals.map { |v| "#{header}: #{v}" }
          end
        }.flatten
      end

    end

    self.extend ClassMethods
  end
end