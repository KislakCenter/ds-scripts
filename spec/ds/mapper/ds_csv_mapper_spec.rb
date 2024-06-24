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
      Recon::Type::AllSubjects, Recon::Type::Genres, Recon::Type::Languages,
      Recon::Type::Materials, Recon::Type::Names, Recon::Type::Places,
      Recon::Type::Titles,
    ]
  }

  let(:subject) { mapper }
  let(:source_path) { File.join source_dir, entry.filename }
  let(:extractor) {  DS::Extractor::DsCsvExtractor }
  context 'mapper implementation' do
    it_behaves_like 'an extractor mapper'
  end

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
    let(:source_file_path) { File.join source_dir, entry.filename }
    it 'implements #extract_record(entry)' do
      expect { mapper.extract_record entry }.not_to raise_error
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
        date_added:                         "",
        date_last_updated:                  "",
        dated:                              "",
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
        production_place_ds_qid:            "QPARIS",
        production_date_as_recorded:        "circa 18th-20th century",
        uniform_title_as_recorded:          "Uniform title",
        uniform_title_agr:                  "Uniform title in vernacular",
        title_as_recorded:                  "Title",
        title_as_recorded_agr:              "Title in vernacular",
        standard_title_ds_qid:              "QTITLE",
        genre_as_recorded:                  "prayer books|Glossaries|A third genre|An AAT term|A second AAT term|An LCGFT term|Another LCGFT term|A FAST term|A second FAST term|An RBMSVC term|An LoBT term",
        genre_ds_qid:                       "|QGENRE|||||||||",
        subject_as_recorded:                "A topical subject|A geographical subject|A chronological subject|A personal named subject|A corporate named subject|A named event|A uniform title subject",
        subject_ds_qid:                     "QTOPICAL||||QNAMEDSUBJECT||",
        author_as_recorded:                 "An author",
        author_as_recorded_agr:             "An author in original script",
        author_ds_qid:                      "QAUTHOR",
        artist_as_recorded:                 "An artist|Another artist",
        artist_as_recorded_agr:             "|Another artist original script",
        artist_ds_qid:                      "QARTIST1|QARTIST",
        scribe_as_recorded:                 "A scribe",
        scribe_as_recorded_agr:             "A scribe in original script",
        scribe_ds_qid:                      "QSCRIBE",
        language_as_recorded:               "Arabic|Farsi",
        language_ds_qid:                    "QARABIC|QFARSI",
        former_owner_as_recorded:           "Former owner as recorded",
        former_owner_as_recorded_agr:       "Former owner in original script",
        former_owner_ds_qid:                "QOWNER",
        associated_agent_as_recorded:       "",
        associated_agent_as_recorded_agr:   "",
        associated_agent_ds_qid:            "",
        material_as_recorded:               "materials description",
        material_ds_qid:                    "QMATERIAL1;QMATERIAL2",
        physical_description:               "Extent: 1 folio; materials description; 310 x 190 mm bound to 320 x 200 mm",
        note:                               "Layout: 1 column, 24 lines|Script: Carolingian|Decoration: Illuminated manuscript|Binding: Bound in vellum|Other miscellaneous physical description|Provenance: Purchased from Phillip J. Pirages Fine Books and Manuscripts, McMinnville, Oregon, 2017|The first note|The second note",
        data_processed_at:                  be_some_kind_of_date_time,
        data_source_modified:               be_some_kind_of_date_time,
        source_file:                        "ucriverside-dscsv.csv",
        acknowledgments:                    "Imad Bayoun and Ahmad AlKurdy helped to identify and describe this manuscript"
      }
    }

    it 'maps a record' do
      expect(mapper.map_record entry).to match expected_map
    end
  end
end
