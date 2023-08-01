# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::MarcMapper' do

  let(:manifest_row) { parse_csv(<<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,DS10000,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
  EOF
  ).first
  }

  let(:entry) { DS::Manifest::Entry.new manifest_row }

  let(:marc_xml_dir) {
    fixture_path 'marc_xml'
  }

  let(:xml_file) {
    File.join marc_xml_dir, '9951865503503681_marc.xml'
  }

  let(:record) {
    xml = File.open(xml_file) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!
    xml.xpath('//record').first
  }

  let(:timestamp) { Time.now }

  let(:mapper) {
    DS::Mapper::MarcMapper.new(
      manifest_entry: entry, record: record,
      timestamp: timestamp
    )
  }

  context 'initialize' do
    it 'creates a DS::Mapper::MarcMapper' do
      expect(
        DS::Mapper::MarcMapper.new(
          manifest_entry: entry, record: record,
          timestamp: timestamp
        )
      ).to be_a DS::Mapper::MarcMapper
    end
  end

  context 'map_record' do
    it 'returns a hash' do
      # Recon lookup is slow; stub .lookup for all Recon classes
      recons = [
        Recon::AllSubjects, Recon::Genres, Recon::Languages,
        Recon::Materials, Recon::Names, Recon::Places,
        Recon::Titles,
      ]
      add_stubs recons, :lookup, []

      expect(mapper.map_record).to be_a Hash
    end
  end
end