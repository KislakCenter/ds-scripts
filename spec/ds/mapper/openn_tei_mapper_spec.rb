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

    it 'returns a hash' do
      add_stubs recons, :lookup, []
      expect(mapper.map_record).to be_a Hash
    end

    it 'extracts artist' do

    end
  end
end