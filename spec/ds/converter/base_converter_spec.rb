# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Converter::BaseConverter' do

  let(:manifest_csv) { parse_csv(<<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,DS10000,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
  EOF
  )
  }

  let(:marc_xml_dir) {
    fixture_path 'marc_xml'
  }

  let(:xml_file) {
    File.join marc_xml_dir, '9951865503503681_marc.xml'
  }

  let(:record) {
    File.open(xml_file) { |f| Nokogiri::XML(f) }
  }

  let(:manifest) {
    DS::Manifest::Manifest.new manifest_csv, marc_xml_dir
  }

  let(:entry) { manifest.first }

  let(:converter) {
    DS::Converter::BaseConverter.new(
      manifest: manifest, source_dir: marc_xml_dir
    )
  }

  context 'initialize' do
    it 'creates a new DS::Converter::BaseConverter' do
      expect(
        DS::Converter::BaseConverter.new(
          manifest: manifest, source_dir: marc_xml_dir
        )
      ).to be_a DS::Converter::BaseConverter
    end
  end

  context 'get_mapper' do
    it 'gets a MarcMapper' do
      expect(
        converter.get_mapper(entry, record, Time.now)
      ).to be_a DS::Mapper::MarcMapper
    end
  end

  context 'retrieve_record' do
    let(:record) { converter.retrieve_record entry }

    it 'returns an XML node' do
      expect(record).to be_a Nokogiri::XML::Element
    end

    it 'returns the correct record' do
      expect(
        record.xpath('controlfield[@tag="001"]').text
      ).to eq '9951865503503681'
    end
  end

  context 'each' do
    it 'yields an entry and a record' do
      expect { |b|
        converter.each &b
      }.to yield_with_args DS::Manifest::Entry, Nokogiri::XML::Element
    end
  end

  context 'context' do
    it 'yields a hash' do
      expect { |b|
        converter.convert &b
      }.to yield_with_args Hash
    end
  end

end