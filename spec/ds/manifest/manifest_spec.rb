# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe 'DS::Manifest' do

  let(:parsed_csv) { parse_csv <<~EOF
    holding_institution_ds_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,dated,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"controlfield[@tag='001']/text()",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,true,2023-07-25T09:52:02-0400
  EOF
  }

  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_path) { File.join marc_xml_dir, 'manifest.csv'}
  let(:manifest_dir) { File.dirname manifest_path }
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
      let(:manifest) { DS::Manifest::Manifest.new manifest_path }
      let(:source_dir) { manifest.source_dir }

      it 'uses the directory from the CSV path' do
        expect(File.directory? source_dir).to be_truthy
      end
    end
  end

  context '#source_dir' do
    it 'is implemented' do
      expect(manifest).to respond_to :source_dir
    end

    it "doesn't raise an error" do
      expect { manifest.source_dir }.not_to raise_error
    end
  end
  context 'when manifest is initialized with dir' do
    context '#source_dir' do
      let(:dir) { 'some_dir' }
      let(:manifest) {
        DS::Manifest::Manifest.new manifest_path, dir
      }

      it 'returns the directory of source_dir' do
        expect(manifest.source_dir).to eq dir
      end
    end
  end

  context 'when manifest is initialized without dir' do
    context '#source_dir' do
      let(:manifest) { DS::Manifest::Manifest.new manifest_path }
      let(:csv_dir) { File.dirname manifest_path }

      it 'returns the directory of input CSV path' do
        expect(manifest.source_dir).to eq csv_dir
      end
    end
  end
end
