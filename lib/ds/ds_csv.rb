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
      title_as_recorded:                  "Title(s)",
      genre_as_recorded:                  "Genre/Form",
      subject_as_recorded:                [
                                            "Named Subject(s)",
                                            "Subject(s)",
                                          ],
      named_subject_as_recorded:          "NOT IMPLEMENTED",
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
      acknowledgments:                    "Acknowledgements",
      date_source_modified:               "Date Updated by Contributor",
    }.freeze

    module ClassMethods

      # @todo implement extract_recon_places
      def extract_recon_places record
        extract_places(record, :production_place_as_recorded).map &:to_a
      end

      # @todo implement extract_recon_titles
      def extract_recon_titles record
        extract_titles(record, :title_as_recorded, 'as_recorded').map &:to_a
      end

      # @todo implement extract_recon_subjects
      def extract_recon_subjects record
        extract_terms(record, :subject_as_recorded).map &:to_a
      end

      # @todo implement extract_recon_genres
      def extract_recon_genres record
        extract_terms(record, :genre_as_recorded).map &:to_a
      end

      # @todo implement extract_recon_names
      def extract_recon_names record
        names = []
        names += extract_names(record, :author_as_recorded, 'author').map(&:to_a)
        names += extract_names(record, :artist_as_recorded, 'artist').map(&:to_a)
        names += extract_names(record, :scribe_as_recorded, 'scribe').map(&:to_a)
        names += extract_names(record, :former_owner_as_recorded, 'former owner').map(&:to_a)
        names
      end

      # @todo implement extract_names
      def extract_physical_description record
        extent = extract_extent record
        material = extract_material_as_recorded record
        dimensions = extract_dimensions record
        desc = [ extent, material, dimensions ].flatten
        return unless desc.any?(&:present?)
        "Extent: #{desc.join '; '}"
      end

      def extract_date_range record, separator: '-'
        start_date = extract_production_date_start record
        end_date   = extract_production_date_end record
        [start_date,end_date].select(&:present?).join separator
      end

      def method_missing name, *args, **kwargs
        return super unless maps_to_property? name
        record = args.first
        extract_value name, record
      end

      def extract_value method_name, record
        prop_name = get_property_name method_name
        extract_values_for prop_name, record
      end

      def extract_author_as_recorded record
        extract_names(record, :author_as_recorded, 'author').map(&:as_recorded)
      end

      def extract_author_as_recorded_agr record
        extract_names(record, :author_as_recorded, 'author').map(&:vernacular)
      end

      def extract_artist_as_recorded record
        extract_names(record, :artist_as_recorded, 'artist').map(&:as_recorded)
      end

      def extract_artist_as_recorded_agr record
        extract_names(record, :artist_as_recorded, 'artist').map(&:vernacular)
      end

      def extract_scribe_as_recorded record
        extract_names(record, :scribe_as_recorded, 'scribe').map(&:as_recorded)
      end

      def extract_scribe_as_recorded_agr record
        extract_names(record, :scribe_as_recorded, 'scribe').map(&:vernacular)
      end

      def extract_former_owner_as_recorded record
        extract_names(record, :former_owner_as_recorded, 'former_owner').map(&:as_recorded)
      end

      def extract_former_owner_as_recorded_agr record
        extract_names(record, :former_owner_as_recorded, 'former_owner').map(&:vernacular)
      end

      def extract_title_as_recorded record
        extract_titles(record, :title_as_recorded, 'as_recorded').map(&:as_recorded)
      end

      def extract_title_as_recorded_agr record
        extract_titles(record, :title_as_recorded, 'as_recorded').map(&:vernacular)
      end

      def extract_uniform_title_as_recorded record
        extract_titles(record, :uniform_title_as_recorded, 'uniform').map(&:as_recorded)
      end

      def extract_uniform_title_as_recorded_agr record
        extract_titles(record, :uniform_title_as_recorded, 'uniform').map(&:vernacular)
      end

      ##
      # Return titles as an array of DS::Extractor::Title instances.
      # Title as recorded and vernacular values are in single columns:
      #
      #     Uniform Title(s)
      #     Al-Hajj;;الجزء التاسع
      #
      # Titles are divided by pipe characters and as recorded and
      # vernacular forms of a title are separated by double semicolons:
      # +;;+.
      #
      # @param [CSV::Row] record a CSV row with headers
      # @param [Symbol] property a valid property name; e.g., +:title_as_recorded+
      # @param [String] title_type the name role; e.g., +uniform+
      # @return [Array<DS::Extractor::Title>] the names a list
      def extract_titles record, property, title_type
        extract_values_for(property, record).map { |name|
          as_recorded, vernacular = name.to_s.split ';;', 2
          DS::Extractor::Title.new as_recorded: as_recorded, vernacular: vernacular, title_type: title_type
        }
      end

      ##
      # Return names as an array DS::Extractor::Name instances. Name
      # as recorded and vernacular values are in single columns:
      #
      #     Author Name(s)
      #     An author;;An author in original script|Another author
      #
      # Names are divided by pipe characters and as recorded and
      # vernacular forms of a name are separated by double semicolons:
      # +;;+.
      #
      # @param [CSV::Row] record a CSV row with headers
      # @param [Symbol] property a valid property name; e.g., +:artist_as_recorded+
      # @param [String] role the name role; e.g., +artist+
      # @return [Array<DS::Extractor::Name>] the names a list
      def extract_names record, property, role
        extract_values_for(property, record).map { |name|
          as_recorded, vernacular = name.to_s.split ';;', 2
          DS::Extractor::Name.new as_recorded: as_recorded, vernacular: vernacular, role: role
        }
      end

      def extract_place_as_recorded record
        extract_places(record, :production_place_as_recorded).map &:as_recorded
      end

      def extract_places record, property
        extract_values_for(property, record).map { |place|
          DS::Extractor::Place.new as_recorded: place
        }
      end

      def extract_genre_as_recorded record
        extract_terms(record, :genre_as_recorded).map(&:as_recorded)
      end

      def extract_subject_as_recorded record
        extract_terms(record, :subject_as_recorded).map(&:as_recorded)
      end

      def extract_terms record, property
        extract_values_for(property, record).map { |term|
          DS::Extractor::Term.new as_recorded: term
        }
      end

      def extract_values_for property, record
        raise "Unknown property: #{property}" unless known_property? property
        columns = [COLUMN_MAPPINGS[property.to_sym]].flatten
        columns.filter_map { |header|
          record[header]
        }.flatten.flat_map { |value| value.split '|'  }
      end

      def extract_date_source_modified record
        extract_values_for(:date_source_modified, record).first
      end

      def respond_to_missing? method_name, *args, &block
        maps_to_property? method_name
      end

      def maps_to_property? method_name
        prop_name = get_property_name method_name
        return unless prop_name
        known_property? prop_name
      end

      def known_property? property
        COLUMN_MAPPINGS.include? property.to_sym
      end

      def get_property_name method_name
        return unless method_name.to_s =~ /^extract_\w+/
        method_name.to_s.split(/_/, 2).last
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
