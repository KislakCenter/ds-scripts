# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe 'DS::ManifestValidator' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  let(:validator) {
    DS::ManifestValidator.new
  }

  let(:valid_csv) {
<<~EOF
      holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
      Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3rd1b/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9951865503503681,2023-07-25T09:52:02-0400
      Q49117,9957602663503681_marc.xml,University of Pennsylvania,MARC XML,,9957602663503681,"//marc:controlfield[@tag=""001""]",20220803105833,LJS 108,Manuscript leaf from Interpretationes Hebraicorum nominum,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3gw56/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9957602663503681,2023-07-25T09:52:02-0400
EOF
  }

  context 'validate_columns' do
    before(:each) do
      allow($stderr).to receive(:puts)
      allow($stderr).to receive(:write)
    end

    context 'with valid columns' do

      let(:csv_data) { CSV.parse valid_csv, headers: true }

      it 'is truthy' do
        expect(validator.validate_columns csv_data).to be_truthy
      end
    end

    context 'with missing columns' do
      let(:csv) {
<<~EOF
          holding_institution_wikidata_qid,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
          Q49117,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3rd1b/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9951865503503681,2023-07-25T09:52:02-0400
          Q49117,University of Pennsylvania,MARC XML,,9957602663503681,"//marc:controlfield[@tag=""001""]",20220803105833,LJS 108,Manuscript leaf from Interpretationes Hebraicorum nominum,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3gw56/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9957602663503681,2023-07-25T09:52:02-0400
EOF
      }

      let(:csv_data) { CSV.parse csv, headers: true }

      it 'is falsey' do
        expect(validator.validate_columns csv_data).to be_falsey
      end
    end


  end

  context 'validate_required_values' do
    context 'with all values present' do
      let(:csv_data) { CSV.parse valid_csv, headers: true }

      it 'is truthy' do
        expect(validator.validate_required_values csv_data).to be_truthy
      end
    end

    context 'with missing values' do
      before(:each) do
        allow($stderr).to receive(:puts)
        allow($stderr).to receive(:write)
      end
      let(:csv) {
        <<~EOF
      holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
      ,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3rd1b/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9951865503503681,2023-07-25T09:52:02-0400
      Q49117,,University of Pennsylvania,MARC XML,,9957602663503681,"//marc:controlfield[@tag=""001""]",20220803105833,LJS 108,Manuscript leaf from Interpretationes Hebraicorum nominum,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3gw56/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9957602663503681,2023-07-25T09:52:02-0400
        EOF
      }

      let(:csv_data) { CSV.parse csv, headers: true }

      it 'is falsey' do
        expect(validator.validate_required_values csv_data).to be_falsey
      end
    end
  end
end