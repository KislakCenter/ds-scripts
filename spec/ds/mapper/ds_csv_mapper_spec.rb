# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::DSCSVMapper do

  let(:source_dir) { fixture_path 'ds_csv' }
  let(:manifest_file) { File.join source_dir, 'ucriverside-manifest.csv' }
  let(:parsed_manifest) { CSV.parse File.open(manifest_file).read, headers: true }
  let(:manifest_row) { parsed_manifest.first }
  let(:manifest) { DS::Manifest::Manifest.new manifest_file, source_dir }
  let(:entry) { DS::Manifest::Entry.new manifest_row, manifest }
  let(:mapper) { DS::Mapper::DSCSVMapper.new(source_dir: source_dir, timestamp: Time.now) }

  let(:recon_classes) {
    [
      Recon::AllSubjects, Recon::Genres, Recon::Languages,
      Recon::Materials, Recon::Names, Recon::Places,
      Recon::Titles,
    ]
  }

  let(:extractor_methods) {
    %i{
        extract_cataloging_convention
        extract_production_date_as_recorded
        extract_production_places_as_recorded
        extract_uniform_titles_as_recorded
        extract_uniform_titles_as_recorded_agr
        extract_titles_as_recorded
        extract_titles_as_recorded_agr
        extract_genres_as_recorded
        extract_all_subjects_as_recorded
        extract_authors_as_recorded
        extract_authors_as_recorded_agr
        extract_artists_as_recorded
        extract_artists_as_recorded_agr
        extract_scribes_as_recorded
        extract_scribes_as_recorded_agr
        extract_former_owners_as_recorded
        extract_former_owners_as_recorded_agr
        extract_languages_as_recorded
        extract_physical_description
        extract_material_as_recorded
        extract_notes
        extract_date_source_modified
      }
  }

  context '#extract_record' do

    it 'returns an CSV row' do
      expect(mapper.extract_record entry).to be_a CSV::Row
    end

    let(:institutional_id) { entry.institutional_id }
    let(:id_location) { entry.institutional_id_location_in_source }
    let(:record) { mapper.extract_record entry }

    it 'returns the expected record' do
      expect(record[id_location]).to eq entry.institutional_id
    end
  end

  context 'DS::Mapper::BaseMapper implementation' do
    it 'implements #extract_record(entry)' do
      expect { mapper.extract_record entry }.not_to raise_error
    end

    it 'implements #open_source(entry)' do
      expect { mapper.open_source entry }.not_to raise_error
    end

    it 'is a kind of BaseMapper' do
      expect(mapper).to be_a_kind_of DS::Mapper::BaseMapper
    end
  end

  context '.initialize' do
    it 'creates a DS::Mapper::DSCSVMapper' do
      expect(
        DS::Mapper::DSCSVMapper.new(
          source_dir: source_dir,
          timestamp: Time.now
        )
      ).to be_a DS::Mapper::DSCSVMapper
    end
  end

  context '#map_record' do

    it 'returns a hash' do
      add_stubs recon_classes, :lookup, []
      expect(mapper.map_record entry).to be_a Hash
    end

    let(:expected_map) {
      {
        ds_id:                              "DS1234",
        source_type:                        "ds-csv",
        cataloging_convention:              "amremm",
        holding_institution:                "Q1075148",
        holding_institution_as_recorded:    "University of California, Riverside",
        holding_institution_id_number:      "BP128.57 .A2 1700z",
        holding_institution_shelfmark:      "BP128.57 .A2 1700z",
        link_to_holding_institution_record: "http://example.com/holding_int_url",
        iiif_manifest:                      "http://example.com/iiif",
        production_date:                    "1700^1999",
        century:                            "18;19;20",
        century_aat:                        "http://vocab.getty.edu/aat/300404512;http://vocab.getty.edu/aat/300404513;http://vocab.getty.edu/aat/300404514",
        production_place_as_recorded:       "Paris",
        production_place:                   "http://vocab.getty.edu/tgn/paris_id",
        production_place_label:             "Paris",
        production_date_as_recorded:        "circa 18th-20th century",
        extract_titles_as_recorded:         "Uniform title",
        uniform_title_agr:                  "Uniform title in vernacular",
        title_as_recorded:                  "Title",
        title_as_recorded_agr:              "Title in vernacular",
        standard_title:                     "Standard title",
        genre_as_recorded:                  "prayer books|Glossaries|A third genre|An AAT term|A second AAT term|An LCGFT term|Another LCGFT term|A FAST term|A second FAST term|An RBMSVC term|An LoBT term",
        genre:                              "|http://vocab.getty.edu/aat/300026189|||||||||",
        genre_label:                        "|glossaries|||||||||",
        subject_as_recorded:                "A topical subject|A geographical subject|A chronological subject|A personal named subject|A corporate named subject|A named event|A uniform title subject",
        subject:                            "http://id.worldcat.org/fast/topical_subject||||http://id.worldcat.org/fast/named_subject||",
        subject_label:                      "Topical auth label||||Named subject auth label||",
        author_as_recorded:                 "An author",
        author_as_recorded_agr:             "An author in original script",
        author_wikidata:                    "WDQIDAUTHOR",
        author:                             "",
        author_instance_of:                 "human",
        author_label:                       "Author auth name",
        artist_as_recorded:                 "An artist|Another artist",
        artist_as_recorded_agr:             "|Another artist original script",
        artist_wikidata:                    "|WDQIDARTIST",
        artist:                             "",
        artist_instance_of:                 "|human",
        artist_label:                       "|Artist auth name",
        scribe_as_recorded:                 "A scribe",
        scribe_as_recorded_agr:             "A scribe in original script",
        scribe_wikidata:                    "WDQIDSCRIBE",
        scribe:                             "",
        scribe_instance_of:                 "human",
        scribe_label:                       "Scribe auth name",
        language_as_recorded:               "Arabic|Farsi",
        language:                           "Q13955|Q9168",
        language_label:                     "Arabic|Persian",
        former_owner_as_recorded:           "Former owner as recorded",
        former_owner_as_recorded_agr:       "Former owner in original script",
        former_owner_wikidata:              "WDQIDOWNER",
        former_owner:                       "",
        former_owner_instance_of:           "organization",
        former_owner_label:                 "Former owner auth name",
        material_as_recorded:               "materials description",
        material:                           "http://vocab.getty.edu/aat/300014109;http://vocab.getty.edu/aat/300011851",
        material_label:                     "parchment;paper",
        physical_description:               "Extent: 1 folio; materials description; 310 x 190 mm bound to 320 x 200 mm",
        note:                               "Layout: 1 column, 24 lines|Script: Carolingian|Decoration: Illuminated manuscript|Binding: Bound in vellum|Other miscellaneous physical description|Provenance: Purchased from Phillip J. Pirages Fine Books and Manuscripts, McMinnville, Oregon, 2017|The first note|The second note",
        data_processed_at:                  be_a_kind_of(Time),
        data_source_modified:               "2024-03-01",
        source_file:                        "ucriverside-dscsv.csv",
        acknowledgments:                    "Imad Bayoun and Ahmad AlKurdy helped to identify and describe this manuscript"
      }
    }

    it 'maps a record' do
      expect(mapper.map_record entry).to match expected_map
    end

    it 'calls all the DSSCV methods' do
      add_stubs recon_classes, :lookup, []
      add_expects objects: DS::DsCsv, methods: extractor_methods, return_val: []

      mapper.map_record entry
    end

    it 'calls lookup on all the Recon classes' do
      add_expects objects: recon_classes, methods: [:lookup], return_val: []
      mapper.map_record entry
    end
  end
end
