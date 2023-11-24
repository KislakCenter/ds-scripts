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
  let(:manifest_path) { File.join marc_xml_dir, 'manifest.csv'}
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, marc_xml_dir }

  context 'initialize' do

    it 'creates a Manifest from a manifest path' do
      expect(
        DS::Manifest::Manifest.new manifest_path, marc_xml_dir
      ).to be_a DS::Manifest::Manifest
    end

    context 'when CSV is a manifest path' do
      it 'sets #csv correctly' do
        expect(
          DS::Manifest::Manifest.new(manifest_path, marc_xml_dir).csv.first
        ).to be_a CSV::Row
      end
    end

    context 'when source dir is nil' do

      it 'uses the directory from the CSV path' do
        expect(
          DS::Manifest::Manifest.new manifest_path
        ).to be_a DS::Manifest::Manifest
      end

    end
  end
end