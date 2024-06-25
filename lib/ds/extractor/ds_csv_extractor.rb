require 'csv'

module DS
  module Extractor
    module DsCsvExtractor
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
        production_places_as_recorded:      "Production Place(s)",
        production_date_as_recorded:        "Date Description",
        production_date_start:              "Production Date START",
        production_date_end:                "Production Date END",
        dated:                              "Dated",
        uniform_titles_as_recorded:         "Uniform Title(s)",
        titles_as_recorded:                 "Title(s)",
        genres_as_recorded:                 "Genre/Form",
        all_subjects:                       [
                                              "Subject(s)",
                                              "Named Subject(s)",
                                            ],
        subjects_as_recorded:               "Subject(s)",
        named_subjects_as_recorded:         "Named Subject(s)",
        authors_as_recorded:                "Author Name(s)",
        artists_as_recorded:                "Artist Name(s)",
        scribes_as_recorded:                "Scribe Name(s)",
        former_owners_as_recorded:          "Former Owner Name(s)",
        languages_as_recorded:              "Language(s)",
        material_as_recorded:               "Materials Description",
        extent:                             "Extent",
        dimensions:                         "Dimensions",
        notes:                              [
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

        # Extracts the DSID value from the given record.
        #
        # @param [CSV::Row] record the record to extract the DSID from
        # @return [String] the extracted DSID value
        def extract_dsid record
          [extract_values_for(:dsid, record)].flatten.first
        end

        # Extracts the source type value from the given record.
        #
        # @param [CSV::Row] record the record to extract the source type from
        # @return [String] the extracted source type value
        def extract_source_type record
          extract_values_for(:source_type, record).first
        end

        # Extracts the cataloging convention value from the given record.
        #
        # @param [CSV::Row] record the record to extract the cataloging convention from
        # @return [String] the extracted cataloging convention value
        def extract_cataloging_convention record
          extract_values_for(:cataloging_convention, record).first
        end

        # Extracts the cataloging convention value from the given record.
        #
        # @param [CSV::Row] record the record to extract the cataloging convention from
        # @return [String] the extracted cataloging convention value
        def extract_holding_institution_as_recorded record
          extract_values_for(:holding_institution_as_recorded, record).first
        end

        # Extracts the institutional identifier (e.g., BibID) from the given record.
        #
        # @param [CSV::Row] record the record to extract the cataloging convention from
        # @return [String] the institutional identifier for the manuscript
        def extract_holding_institution_id_number record
          extract_values_for(:holding_institution_id_number, record).first
        end

        # Extracts the holding institution shelfmark from the given record.
        #
        # @param [CSV::Row] record the record to extract the holding institution shelfmark from
        # @return [String] the extracted holding institution shelfmark value
        def extract_holding_institution_shelfmark record
          extract_values_for(:holding_institution_shelfmark, record).first
        end

        # Extracts the fragment number or disambiguator value from the given record.
        #
        # @param [CSV::Row] record the record to extract the fragment number or disambiguator from
        # @return [String] the extracted fragment number or disambiguator value
        def extract_fragment_num_disambiguator record
          extract_values_for(:fragment_num_disambiguator, record).first
        end

        # Extracts the link to the holding institution record from the given record.
        #
        # @param [CSV::Row] record the record to extract the link from
        # @return [String] the extracted link to the holding institution record
        def extract_link_to_holding_institution_record record
          extract_values_for(:link_to_holding_institution_record, record).first
        end

        # Extracts the link to the IIIF manifest from the given record.
        #
        # @param [CSV::Row] record the record to extract the link from
        # @return [String] the extracted link to the IIIF manifest
        def extract_link_to_iiif_manifest record
          extract_values_for(:link_to_iiif_manifest, record).first
        end

        # Extracts the production date as recorded value from the given record.
        #
        # @param [CSV::Row] record the record to extract the production date from
        # @return [Array<String>] the extracted production dates
        def extract_production_date_as_recorded record
          extract_values_for(:production_date_as_recorded, record)
        end


        # Extracts the date range from the given record using the specified separator.
        #
        # @param [CSV::Row] record the record to extract the date range from
        # @param [String] range_sep the separator to be used in the date range
        # @return [Array<String>] the extracted date range
        def extract_date_range record, range_sep:
          start_date = extract_production_date_start record
          end_date   = extract_production_date_end record
          range = [start_date, end_date].select(&:present?)
          return [] if range.blank?
          [range.join(range_sep)]
        end

        # Extracts the production date start value from the given record.
        #
        # @param [CSV::Row] record the record to extract the production date start from
        # @return [String] the extracted production date start value
        def extract_production_date_start record
          extract_values_for(:production_date_start, record).first
        end

        # Extracts the production date end value from the given record.
        #
        # @param [CSV::Row] record the record to extract the production date end from
        # @return [String] the extracted production date end value
        def extract_production_date_end record
          extract_values_for(:production_date_end, record).first
        end

        # Extracts the dated value from the given record.
        #
        # @param [CSV::Row] record the record to extract the dated value from
        # @return [Boolean] true if the dated value is 'true', false otherwise
        def extract_dated record
          dated = extract_values_for(:dated, record)
          return true if dated.join.strip.downcase == 'true'
        end

        # @todo implement extract_names
        # Extracts the physical description from the given record.
        #
        # @param [CSV::Row] record the record to extract the physical description from
        # @return [Array<String>] the extracted physical description
        def extract_physical_description record
          extent     = extract_values_for :extent, record
          material   = extract_values_for :material_as_recorded, record
          dimensions = extract_dimensions record
          desc       = [extent, material, dimensions].flatten
          return unless desc.any?(&:present?)
          ["Extent: #{desc.join '; '}"]
        end

        # Extracts the dimensions from the given record.
        #
        # @param [CSV::Row] record the record to extract the dimensions from
        # @return [Array<String>] the extracted dimensions
        def extract_dimensions record
          extract_values_for :dimensions, record
        end

        # Extracts authors as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract authors from
        # @return [Array<String>] the extracted authors as recorded
        def extract_authors_as_recorded record
          extract_authors(record).map &:as_recorded
        end

        # Extracts authors as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract authors from
        # @return [Array<String>] the extracted authors as recorded with vernacular form
        def extract_authors_as_recorded_agr record
          extract_authors(record).map &:vernacular
        end

        # Extracts authors from the given record using the specified type and role.
        #
        # @param [CSV::Row] record the record to extract authors from
        # @return [Array<String>] the extracted authors
        def extract_authors record
          extract_names(record, :authors_as_recorded, 'author')
        end

        # Extracts artists as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract artists from
        # @return [Array<String>] the extracted artists as recorded
        def extract_artists_as_recorded record
          extract_artists(record).map &:as_recorded
        end

        # Extracts artists as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract artists from
        # @return [Array<String>] the extracted artists as recorded with vernacular form
        def extract_artists_as_recorded_agr record
          extract_artists(record).map &:vernacular
        end

        # Extracts artists from the given record using the specified type and role.
        #
        # @param [CSV::Row] record the record to extract artists from
        # @return [Array<String>] the extracted artists
        def extract_artists record
          extract_names(record, :artists_as_recorded, 'artist')
        end

        # Extracts scribes as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract scribes from
        # @return [Array<String>] the extracted scribes as recorded
        def extract_scribes_as_recorded record
          extract_scribes(record).map &:as_recorded
        end

        # Extracts scribes as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract scribes from
        # @return [Array<String>] the extracted scribes as recorded with vernacular form
        def extract_scribes_as_recorded_agr record
          extract_scribes(record).map &:vernacular
        end

        # Extracts scribes from the given record using the specified type and role.
        #
        # @param [CSV::Row] record the record to extract scribes from
        # @return [Array<String>] the extracted scribes
        def extract_scribes record
          extract_names(record, :scribes_as_recorded, 'scribe')
        end

        # Extracts former owners as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract former owners from
        # @return [Array<String>] the extracted former owners as recorded
        def extract_former_owners_as_recorded record
          extract_former_owners(record).map &:as_recorded
        end

        # Extracts former owners as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract former owners from
        # @return [Array<String>] the extracted former owners as recorded with vernacular form
        def extract_former_owners_as_recorded_agr record
          extract_former_owners(record).map &:vernacular
        end

        # Extracts former owners from the given record using the specified type and role.
        #
        # @param [CSV::Row] record the record to extract former owners from
        # @return [Array<String>] the extracted former owners
        def extract_former_owners record
          extract_names(record, :former_owners_as_recorded, 'former_owner')
        end

        # Extracts associated agents from the given record.
        #
        # @note Method to fulfill DS::Extractor contract; returns an empty array
        #
        # @param [CSV::Row] record the record
        # @return [Array<String>] an empty array
        def extract_associated_agents record
          []
        end

        # Extracts languages as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract languages from
        # @return [Array<String>] the extracted languages as recorded
        def extract_languages_as_recorded record
          extract_languages(record).map &:as_recorded
        end

        # Extracts languages from the given record using the specified type and role.
        #
        # @param [CSV::Row] record the record to extract languages from
        # @return [Array<DS::Extractor::Language>] the extracted languages
        def extract_languages record
          extract_values_for(:languages_as_recorded, record).map { |lang|
            DS::Extractor::Language.new as_recorded: lang
          }
        end

        # Extracts material as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract material from
        # @return [String, nil] the extracted material as recorded
        def extract_material_as_recorded record
          extract_materials(record).map(&:as_recorded).join '|'
        end

        # Extracts materials from the given record.
        #
        # @param [CSV::Row] record the record to extract materials from
        # @return [Array<DS::Extractor::Material>] the extracted materials
        def extract_materials record
          extract_values_for(:material_as_recorded, record).map { |as_recorded|
            DS::Extractor::Material.new as_recorded: as_recorded
          }
        end

        # Extracts titles as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract titles from
        # @return [Array<String>] the extracted titles as recorded
        def extract_titles_as_recorded record
          extract_titles(record).map &:as_recorded
        end

        # Extracts titles as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract titles from
        # @return [Array<String>] the extracted titles as recorded with vernacular form
        def extract_titles_as_recorded_agr record
          extract_titles(record).map &:vernacular
        end

        # Extracts uniform titles as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract uniform titles from
        # @return [Array<String>] the extracted uniform titles as recorded
        def extract_uniform_titles_as_recorded record
          extract_uniform_titles(record).map &:uniform_title
        end

        # Extracts uniform titles as recorded with vernacular form from the given record.
        #
        # @param [CSV::Row] record the record to extract uniform titles from
        # @return [Array<String>] the extracted uniform titles as recorded with vernacular form
        def extract_uniform_titles_as_recorded_agr record
          extract_uniform_titles(record).map &:uniform_title_vernacular
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
        # @return [Array<DS::Extractor::Title>] the names a list
        def extract_titles record
          as_recorded_titles = extract_values_for(:titles_as_recorded, record)
          uniform_titles     = extract_values_for(:uniform_titles_as_recorded, record)
          as_recorded_titles << '' if as_recorded_titles.blank?
          uniform_titles << '' if uniform_titles.blank?
          unless balanced_titles? as_recorded_titles, uniform_titles
            raise ArgumentError, "Unbalanced number of titles and uniform titles (titles: #{as_recorded_titles.inspect}, uniform titles: #{uniform_titles.inspect})"
          end

          as_recorded_titles.zip(uniform_titles).map { |as_rec, uniform|
            as_recorded, vernacular                 = as_rec.split ';;', 2
            uniform_title, uniform_title_vernacular = uniform.split ';;', 2
            DS::Extractor::Title.new(
              as_recorded:              as_recorded,
              vernacular:               vernacular,
              uniform_title:            uniform_title,
              uniform_title_vernacular: uniform_title_vernacular
            )
          }
        end

        # Return true if the as_recorded and uniform titles are of equal length.
        #
        # @param [Array<String>] as_recorded_titles
        # @param [Array<String>] uniform_titles
        # @return [Boolean]
        def balanced_titles? as_recorded_titles, uniform_titles
          return true if as_recorded_titles.blank? && uniform_titles.blank?
          return true if as_recorded_titles.size == uniform_titles.size

          # for our purposes, ['Some title'] and [] are balanced
          return true if [as_recorded_titles, uniform_titles].all? { |arr| arr.length <= 1 }
          false
        end

        ##
        # Note: BaseTerm implementations require +as_recorded+; for DS
        # CSV we don't assume that the Title(s) and Uniform Titles(s)
        # are paralleled so they're handled separately.
        #
        # @todo: Find out whether we should enforce that Titles and
        #   Uniform Titles be evenly paired.
        # Extracts uniform titles from the given record.
        #
        # @param [CSV::Row] record the record to extract uniform titles from
        # @return [Array<DS::Extractor::Title>] the extracted uniform titles
        def extract_uniform_titles record
          extract_values_for(:uniform_titles_as_recorded, record).map { |title|
            as_recorded, vernacular = title.to_s.split ';;', 2
            # BaseTerm implementations require +as_recorded+; for DS CSV
            # we don't assume that the Title(s) and Uniform Titles(s)
            # are paralleled so there handled separately
            DS::Extractor::Title.new as_recorded: nil, uniform_title: as_recorded, uniform_title_vernacular: vernacular
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

        # Extracts production places as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract production places from
        # @return [Array<String>] the extracted production places as recorded
        def extract_production_places_as_recorded record
          extract_places(record, :production_places_as_recorded).map &:as_recorded
        end

        # Extracts places from the given record using the specified property.
        #
        # @param [Symbol] property the property to extract places from the record
        # @param [CSV::Row] record the record to extract places from
        # @return [Array<DS::Extractor::Place>] the extracted places
        def extract_places record, property = :production_places_as_recorded
          extract_values_for(property, record).map { |place|
            DS::Extractor::Place.new as_recorded: place
          }
        end

        # Extracts genres as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract genres from
        # @return [Array<String>] the extracted genres as recorded
        def extract_genres_as_recorded record
          extract_genres(record).map &:as_recorded
        end

        # Extracts genres from the given record.
        #
        # @param [CSV::Row] record the record to extract genres from
        # @return [Array<DS::Extractor::Genre>] the extracted genres
        def extract_genres record
          extract_terms record, :genres_as_recorded, DS::Extractor::Genre, vocab: 'ds-genre'
        end

        # Extracts subjects as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract subjects from
        # @return [Array<String>] the extracted subjects as recorded
        def extract_subjects_as_recorded record
          extract_subjects(record).map &:as_recorded
        end

        # Extracts all subjects as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract all subjects from
        # @return [Array<String>] the extracted all subjects as recorded
        def extract_all_subjects_as_recorded record
          extract_all_subjects(record).map &:as_recorded
        end

        # Extracts all subjects from the given record, including subjects and named subjects.
        #
        # @param [CSV::Row] record the record to extract all subjects from
        # @return [Array<DS::Extractor::Subject>] the extracted all subjects
        def extract_all_subjects record
          extract_subjects(record) + extract_named_subjects(record)
        end

        # Extracts subjects from the given record.
        #
        # @param [CSV::Row] record the record to extract subjects from
        # @return [Array<DS::Extractor::Subject>] the extracted subjects
        def extract_subjects record
          extract_terms record, :subjects_as_recorded, DS::Extractor::Subject, vocab: 'ds-subject'
        end

        # Extracts named subjects as recorded from the given record.
        #
        # @param [CSV::Row] record the record to extract named subjects from
        # @return [Array<String>] the extracted named subjects as recorded
        def extract_named_subjects_as_recorded record
          extract_named_subjects(record).map &:as_recorded
        end

        # Extracts named subjects from the given record.
        #
        # @param [CSV::Row] record the record to extract named subjects from
        # @return [Array<DS::Extractor::Subject>] the extracted named subjects
        def extract_named_subjects record
          extract_terms record, :named_subjects_as_recorded, DS::Extractor::Subject, vocab: 'ds-subject'
        end

        # Extracts terms of a specific type from the given record using the specified property.
        #
        # @param [CSV::Row] record the record to extract terms from
        # @param [Symbol] property the property to extract terms from the record
        # @param [Class] term_type the type of terms to extract
        # @return [Array<term_type>] the extracted terms
        def extract_terms record, property, term_type, vocab: nil
          extract_values_for(property, record).map { |term|
            term_type.new as_recorded: term, vocab: vocab
          }
        end

        # Extracts acknowledgments from the given record.
        #
        # @param [CSV::Row] record the record to extract acknowledgments from
        # @return [Array] the extracted acknowledgments
        def extract_acknowledgments record
          extract_values_for :acknowledgments, record
        end

        # Extracts reconstructed places from the given record.
        #
        # @param [CSV::Row] record the record to extract reconstructed places from
        # @return [Array] the extracted reconstructed places
        def extract_recon_places record
          extract_places(record, :production_places_as_recorded).map &:to_a
        end

        # Extracts reconstructed titles from the given record.
        #
        # @param [CSV::Row] record the record to extract reconstructed titles from
        # @return [Array] the extracted reconstructed titles
        def extract_recon_titles record
          extract_titles(record).map &:to_a
        end

        # Extracts reconstructed subjects from the given record.
        #
        # @param [CSV::Row] record the record to extract reconstructed subjects from
        # @return [Array] the extracted reconstructed subjects
        def extract_recon_subjects record
          extract_all_subjects(record).map &:to_a
        end

        # Extracts reconstructed genres from the given record.
        #
        # @param [CSV::Row] record the record to extract reconstructed genres from
        # @return [Array] the extracted reconstructed genres
        def extract_recon_genres record
          extract_genres(record).map &:to_a
        end

        # @todo implement extract_recon_names
        def extract_recon_names record
          names = []
          names += extract_names(record, :authors_as_recorded, 'author').map(&:to_a)
          names += extract_names(record, :artists_as_recorded, 'artist').map(&:to_a)
          names += extract_names(record, :scribes_as_recorded, 'scribe').map(&:to_a)
          names += extract_names(record, :former_owners_as_recorded, 'former owner').map(&:to_a)
          names
        end

        # Extracts values for a specific property from a record.
        #
        # @param [Symbol] property the property to extract values for
        # @param [CSV::Row] record the record containing the values
        # @return [Array] the extracted values
        def extract_values_for property, record
          raise "Unknown property: #{property}" unless known_property? property
          columns = [COLUMN_MAPPINGS[property.to_sym]].flatten
          columns.filter_map { |header|
            record[header]
            # use split -1 to preserve empty values
          }.flatten.flat_map { |value| value.split '|', -1 }
        end

        # Determines if a method name maps to a property.
        #
        # @param [String] method_name the method name to check
        # @return [Boolean] true if the method name corresponds to a known property, false otherwise
        def maps_to_property? method_name
          prop_name = get_property_name method_name
          return unless prop_name
          known_property? prop_name
        end

        # Determines if a property is known.
        #
        # @param [Symbol] property the property to check if it is known
        # @return [Boolean] true if the property is known, false otherwise
        def known_property? property
          COLUMN_MAPPINGS.include? property.to_sym
        end

        # Determines the property name extracted from the method name.
        #
        # @param [String] method_name the method name to extract the property name from
        # @return [String, nil] the extracted property name or nil if not found
        def get_property_name method_name
          return unless method_name.to_s =~ /^extract_\w+/
          method_name.to_s.split(/_/, 2).last
        end

        # Extracts notes from the given record.
        #
        # @param [CSV::Row] record the record to extract notes from
        # @return [Array<String>] the extracted notes
        def extract_notes record
          COLUMN_MAPPINGS[:notes].filter_map { |header|
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
end
