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
      named_subject_as_recorded:          "NOT IMPLEMENTED",
      author_as_recorded:                 "Author Name(s)",
      author_as_recorded_agr:             "Author Name(s) - Original Script",
      artist_as_recorded:                 "Artist Name(s)",
      artist_as_recorded_agr:             "Artist Name(s) - Original Script",
      scribe_as_recorded:                 "Scribe Name(s)",
      scribe_as_recorded_agr:             "Scribe Name(s) - Original Script",
      former_owner_as_recorded:           "Former Owner Name(s)",
      former_owner_as_recorded_agr:       "Former Owner Names(s) - Original Script",
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
      acknowledgments:                    "Acknowledgements",
      data_source_modified:               "Date Updated by Contributor",
    }.freeze

    module ClassMethods

      # @todo implement extract_recon_places
      def extract_recon_places record; end

      # @todo implement extract_recon_titles
      def extract_recon_titles record; end

      # @todo implement extract_recon_subjects
      def extract_recon_subjects record; end

      # @todo implement extract_recon_genres
      def extract_recon_genres record; end

      # @todo implement extract_recon_names
      def extract_recon_names record; end

      # @todo implement extract_names
      def extract_names record; end

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

      def extract_date_range record, separator: '-'
        start_date = extract_production_date_start record
        end_date   = extract_production_date_end record
        [start_date,end_date].select(&:present?).join separator
      end

      def method_missing name, *args, **kwargs
        return super unless maps_to_property? name
        retrieve_property name, args.first
      end

      def retrieve_property method_name, record
        prop_name = get_property method_name
        columns = [COLUMN_MAPPINGS[prop_name.to_sym]].flatten
        columns.filter_map { |header|
          record[header]
        }.flatten.flat_map { |value| value.split '|'  }
      end

      def respond_to_missing? name, *args, &block
        maps_to_property? name
      end

      def maps_to_property? method_name
        prop_name = get_property method_name
        return unless prop_name
        COLUMN_MAPPINGS.include? prop_name.to_sym
      end

      def get_property name
        return unless name.to_s =~ /^extract_\w+/
        name.to_s.split(/_/, 2).last
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