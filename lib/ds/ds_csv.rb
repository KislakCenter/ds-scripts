require 'csv'

module DS
  module DSCSV
    COLUMN_MAPPINGS = {
      holding_institution_as_recorded:    "Holding Institution",
      source_type:                        "Source Type",
      holding_institution_id_number:      "Holding Institution Identifier",
      holding_institution_shelfmark:      "Shelfmark",
      link_to_holding_institution_record: "IIIF Manifest",
      production_place_as_recorded:       "Production Place(s)",
      production_date_as_recorded:        "Date Description",
      production_date:                    [
                                            "Production Date START",
                                            "Production Date END"
                                          ],
      dated:                              "Dated",
      uniform_title_as_recorded:          "Uniform Title(s)",
      title_as_recorded:                  "Title(s)",
      genre_as_recorded:                  [
                                            "Genre 1",
                                            "Genre 2",
                                            "Genre 3",
                                            "AAT Term(s)",
                                            "LCGFT Term(s)",
                                            "FAST Term(s)",
                                            "RBMSCV Term(s)",
                                            "LoBT Term(s)",
                                          ],
      subject_as_recorded:                [
                                            "Named Subject(s): Personal",
                                            "Named Subject(s): Event",
                                            "Named Subject(s): Uniform Title",
                                            "Named Subject(s): Corporate",
                                            "Subject(s): Topical",
                                            "Subject(s): Geographical",
                                            "Subject(s): Chronological",
                                          ],
      author_as_recorded:                 "Author Name(s)",
      artist_as_recorded:                 "Artist Name(s)",
      scribe_as_recorded:                 "Scribe Name(s)",
      former_owner_as_recorded:           "Former Owner Name(s)",
      language_as_recorded:               "Language(s)",
      material_as_recorded:               "Materials Description",
      material_label:                     [
                                            "Material 1",
                                            "Material 2",
                                            "Material 3",
                                          ],
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
    }.freeze
    module ClassMethods

      def extract_physical_description record
        extent = extract_extent record
        dimensions = extract_dimensions record
        desc = [ extent, dimensions ].flatten
        return unless desc.any?(&:present?)
        "Extent: #{desc.join '; '}"
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