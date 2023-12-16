# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::MarcMapper' do

  let(:manifest) {  }

  let(:manifest_csv) { parse_csv(<<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,DS10000,9951865503503681,"//controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
    Q49117,9949533433503681_marc.xml,University of Pennsylvania,MARC XML,,9949533433503681,"//marc:controlfield[@tag=""001""]",20220803105856,Oversize LJS 280,Decretales a[b]breviate,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3wm13v03/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9949533433503681,2023-08-01T11:31:22-0400

  EOF
  )
  }
  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_path) { File.join marc_xml_dir, 'manifest.csv' }

  let(:manifest_row) { manifest_csv.first }

  let(:manifest) {
    DS::Manifest::Manifest.new manifest_path, marc_xml_dir
  }

  let(:entry) { DS::Manifest::Entry.new manifest_row, manifest }

  let(:xml_file) {
    File.join marc_xml_dir, '9951865503503681_marc.xml'
  }

  let(:timestamp) { Time.now }

  let(:marc_mapper) {
    DS::Mapper::MarcMapper.new(
      source_dir: marc_xml_dir,
      timestamp: timestamp
    )
  }

  let(:recon_classes) {
    [
      Recon::AllSubjects, Recon::Genres, Recon::Languages,
      Recon::Materials, Recon::Names, Recon::Places,
      Recon::Titles,
    ]
  }

  let(:marc_xml_methods) {
    %i{
          extract_cataloging_convention
          extract_001_control_number
          extract_encoded_date_008
          extract_date_as_recorded
          parse_008
          extract_place_as_recorded
          extract_uniform_title_as_recorded
          extract_uniform_title_agr
          extract_title_as_recorded
          extract_title_agr
          extract_genre_as_recorded
          extract_genre_vocabulary
          extract_subject_as_recorded
          extract_authors_as_recorded
          extract_authors_as_recorded_agr
          extract_names_as_recorded
          extract_names_as_recorded_agr
          extract_names_as_recorded
          extract_names_as_recorded_agr
          extract_language_as_recorded
          extract_names_as_recorded
          extract_names_as_recorded_agr
          collect_datafields
          extract_physical_description
          extract_note
          source_modified
        }
  }

  context 'extract_record' do

    it 'returns an XML node' do
      expect(marc_mapper.extract_record entry).to be_a Nokogiri::XML::Element
    end

    let(:institutional_id) { entry.institutional_id }
    let(:xpath) { entry.institutional_id_location_in_source }
    let(:record) { marc_mapper.extract_record entry }

    it 'returns the expected record' do
      expect(record.at_xpath(xpath).text).to eq entry.institutional_id
    end
  end

  context 'DS::Mapper::BaseMapper implementation' do
    it 'implements #extract_record(entry)' do
      expect {
        marc_mapper.extract_record entry
      }.not_to raise_error
    end

    it 'is a kind of BaseMapper' do
      expect(marc_mapper).to be_a_kind_of DS::Mapper::BaseMapper
    end
  end

  context 'initialize' do
    it 'creates a DS::Mapper::MarcMapper' do
      expect(
        DS::Mapper::MarcMapper.new(
          source_dir: marc_xml_dir,
          timestamp: timestamp
        )
      ).to be_a DS::Mapper::MarcMapper
    end
  end

  context 'map_record' do

    it 'returns a hash' do
      add_stubs recon_classes, :lookup, []

      expect(marc_mapper.map_record entry).to be_a Hash
    end

    it 'calls all the MarcXML methods' do
      add_stubs recon_classes, :lookup, []
      add_expects objects: DS::MarcXML, methods: marc_xml_methods, return_val: []
      marc_mapper.map_record entry
    end

  end
end