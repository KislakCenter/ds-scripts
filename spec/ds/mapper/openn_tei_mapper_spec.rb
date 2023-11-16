# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::OPennTEIMapper do

  let(:xml_dir) { fixture_path 'tei_xml' }
  let(:xml_file) { File.join xml_dir, 'lewis_o_031_TEI.xml' }
  let(:record) { xml = File.open(xml_file) { |f| Nokogiri::XML f } }
  let(:timestamp) { Time.now }
  let(:mapper) {
    DS::Mapper::OPennTEIMapper.new(
      record: record, timestamp: timestamp, source_file: xml_file
    )
  }

  context 'initialize' do
    it 'creates a DS::Mapper::OPennTEIMapper' do
      expect(
        DS::Mapper::OPennTEIMapper.new(
          record: record, timestamp: timestamp, source_file: xml_file
        )
      ).to be_a DS::Mapper::OPennTEIMapper
    end
  end

  context 'map_record' do
    let(:recons) {
      [
        Recon::AllSubjects, Recon::Genres, Recon::Languages,
        Recon::Materials, Recon::Names, Recon::Places,
        Recon::Titles,
      ]
    }
    let(:expected_calls) {
      %i{
        extract_holding_institution
        extract_holding_institution_id_nummber
        extract_shelfmark
        extract_link_to_record
        extract_production_place
        extract_title_as_recorded
        extract_title_as_recorded_agr
        extract_material_as_recorded
        extract_authors
        extract_authors_agr
        extract_artists_as_recorded
        extract_artists_agr
        extract_scribes_as_recorded
        extract_scribes_agr
        extract_former_owners_as_recorded
        extract_former_owners_agr
      }
    }


    it 'returns a hash' do
      add_stubs recons, :lookup, []
      expect(mapper.map_record).to be_a Hash
    end

    it 'calls all expected openn_tei methods' do
      add_stubs recons, :lookup, []
      add_expects objects: DS::OPennTEI, methods: expected_calls, args: record, return_val: []
      # extract_production_date gets called 2x, thus the [] , [] returns
      expect(DS::OPennTEI).to receive(:extract_production_date).and_return [], []

      mapper.map_record
    end

    it 'returns a hash with all expected keys' do
      add_stubs recons, :lookup, []
      hash = mapper.map_record
      expect(DS::Constants::HEADINGS - hash.keys).to be_empty
    end
  end
end