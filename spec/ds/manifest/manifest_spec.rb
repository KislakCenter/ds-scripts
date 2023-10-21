# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe 'DS::Manifest' do

  let(:parsed_csv) { parse_csv <<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
  EOF
  }

  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_csv) { 'manifest.csv' }

  let(:manifest) { DS::Manifest::Manifest.new parsed_csv, marc_xml_dir }

  context 'initialize' do

    let(:parsed_csv) { parse_csv <<~EOF
      holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
      Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
    EOF
    }

    it 'creates a new Manifest with parsed CSV' do
      expect(
        DS::Manifest::Manifest.new parsed_csv, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    let(:csv_string) {
      <<~EOF
        holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
        Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
      EOF
    }

    let(:csv_stringio) { StringIO.new csv_string }

    it 'creates a Manifest from a StringIO instance' do
      expect(
        DS::Manifest::Manifest.new csv_stringio, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    let(:manifest_path) { File.join marc_xml_dir, manifest_csv }
    it 'creates a Manifest from a manifest path' do
      expect(
        DS::Manifest::Manifest.new manifest_path, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    let(:csv_file_instance) { File.open manifest_path, "r+" }
    it 'creates a Manifest from an IO instance' do
      expect(
        DS::Manifest::Manifest.new csv_file_instance, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    it 'creates a Manifest from a CSV string' do
      expect(
        DS::Manifest::Manifest.new csv_string, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    context 'when CSV is a manifest path' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(manifest_path, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    context 'when CSV is a StringIO' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(csv_stringio, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    context 'when CSV is a String' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(csv_string, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    context 'when CSV is a File' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(csv_file_instance, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    context 'when CSV is a parse CSV' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(parsed_csv, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    it 'creates a Manifest from a CSV::Table' do
      expect(
        DS::Manifest::Manifest.new parsed_csv, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    context 'when source dir is nil' do

      it 'uses the directory from the CSV path' do
        expect(
          DS::Manifest::Manifest.new manifest_path
        ).to be_a DS::Manifest::Manifest
      end

      it 'uses the directory from a file instance' do
        expect(
          DS::Manifest::Manifest.new csv_file_instance
        ).to be_a DS::Manifest::Manifest
      end

      it 'gets the correct directory from the CSV path' do
        expect(
          DS::Manifest::Manifest.new(manifest_path).source_dir
        ).to eq marc_xml_dir
      end

      it 'gets the correct directory from the file instance' do
        expect(
          DS::Manifest::Manifest.new(csv_file_instance).source_dir
        ).to eq marc_xml_dir
      end

      it 'raises an error when CSV is a String' do
        expect {
          DS::Manifest::Manifest.new csv_string
        }.to raise_error DSError
      end

      it 'raises an error when CSV is StringIO' do
        expect {
          DS::Manifest::Manifest.new csv_stringio
        }.to raise_error DSError
      end

      it 'raises an error when CSV is a parsed CSV' do
        expect {
          DS::Manifest::Manifest.new parsed_csv
        }.to raise_error DSError
      end

    end
  end
end