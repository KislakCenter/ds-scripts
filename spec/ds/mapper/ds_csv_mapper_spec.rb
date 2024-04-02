# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::DSCSVMapper' do

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
        extract_subjects_as_recorded
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

  context 'extract_record' do

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

  context 'initialize' do
    it 'creates a DS::Mapper::DSCSVMapper' do
      expect(
        DS::Mapper::DSCSVMapper.new(
          source_dir: source_dir,
          timestamp: Time.now
        )
      ).to be_a DS::Mapper::DSCSVMapper
    end
  end

  context 'map_record' do

    it 'returns a hash' do
      add_stubs recon_classes, :lookup, []

      expect(mapper.map_record entry).to be_a Hash
    end

    it 'calls all the DSSCV methods' do
      add_stubs recon_classes, :lookup, []
      add_expects objects: DS::DSCSV, methods: extractor_methods, return_val: []

      mapper.map_record entry
    end

    it 'calls lookup on all the Recon classes' do
      add_expects objects: recon_classes, methods: [:lookup], return_val: []
      mapper.map_record entry
    end
  end
end
