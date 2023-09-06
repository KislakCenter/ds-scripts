# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe 'DS::Manifest::ManifestValidator' do


  let(:csv_data) { parse_csv <<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
EOF
  }


  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_csv) { 'manifest.csv' }
  let(:manifest_path) { File.join marc_xml_dir, manifest_csv }
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, marc_xml_dir }

  let(:validator) { DS::Manifest::ManifestValidator.new manifest }

  before(:each) do
    # suppress STDERR
    allow($stderr).to receive(:puts)
    allow($stderr).to receive(:write)
    # use the following to restore STDERR
    # RSpec::Mocks.space.proxy_for($stderr).reset
  end

  context 'initialize' do

    it 'creates a new ManifestValidator' do
      expect(DS::Manifest::ManifestValidator.new manifest).to be_a DS::Manifest::ManifestValidator
    end
  end

  context 'valid?' do

    context "a valid csv" do
      it 'is valid' do
        RSpec::Mocks.space.proxy_for($stderr).reset
        expect(validator.valid?)
      end
    end

    context 'when run' do
      SUB_VALIDATIONS = %i{
        validate_columns validate_required_values validate_data_types
        validate_files_exist validate_ids
      }

      it 'calls validate_columns'do
        add_stubs validator, SUB_VALIDATIONS, true

        expect(validator).to receive(:validate_columns)
        validator.valid?
      end

      it 'calls validate_required_values'do
        add_stubs validator, SUB_VALIDATIONS, true

        expect(validator).to receive(:validate_required_values)
        validator.valid?
      end

      it 'calls validate_data_types'do
        add_stubs validator, SUB_VALIDATIONS, true

        expect(validator).to receive(:validate_data_types)
        validator.valid?
      end

      it 'calls validate_files_exist'do
        add_stubs validator, SUB_VALIDATIONS, true

        expect(validator).to receive(:validate_files_exist)
        validator.valid?
      end

      it 'call validate_ids'do
        add_stubs validator, SUB_VALIDATIONS, true

        expect(validator).to receive(:validate_ids)
        validator.valid?
      end
    end
  end

  context 'validate_columns' do
    context 'with valid columns' do
      it 'is truthy' do
        expect(validator.validate_columns).to be_truthy
      end
    end

    context 'with missing columns' do
      let(:csv_data) { StringIO.new <<~EOF
        holding_institution_wikidata_qid,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
        Q49117,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3rd1b/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9951865503503681,2023-07-25T09:52:02-0400
        Q49117,University of Pennsylvania,MARC XML,,9957602663503681,"//marc:controlfield[@tag=""001""]",20220803105833,LJS 108,Manuscript leaf from Interpretationes Hebraicorum nominum,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3gw56/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9957602663503681,2023-07-25T09:52:02-0400
EOF
      }
      let(:manifest) { DS::Manifest::Manifest.new csv_data, marc_xml_dir}
      let(:validator) { DS::Manifest::ManifestValidator.new manifest }

      it 'is falsey' do
        expect(validator.validate_columns).to be_falsey
      end
    end


  end

  context 'validate_required_values' do
    context 'with all values present' do

      it 'is truthy' do
        expect(validator.validate_required_values).to be_truthy
      end
    end

    context 'with missing values' do
      let(:csv_data) { StringIO.new <<~EOF
        holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
        ,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3rd1b/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9951865503503681,2023-07-25T09:52:02-0400
        EOF
      }
      let(:manifest) { DS::Manifest::Manifest.new csv_data, marc_xml_dir }
      let(:validator) { DS::Manifest::ManifestValidator.new manifest }

      it 'is falsey' do
        expect(validator.validate_required_values).to be_falsey
      end
    end
  end

  context 'validate_urls' do

    context "for a valid url" do
      it 'is truthy' do
        expect(validator.validate_urls csv_data.first, 0).to be_truthy
      end

    end


    context "for an invalid url" do
      let(:csv_data) { parse_csv <<~EOF
        iiif_manifest_url,link_to_institutional_record
        httpx://bad-example.com,
      EOF
      }

      it 'is falsey' do
        expect(validator.validate_urls csv_data.first, 0).to be_falsey
      end
    end

    context "for an empty URL" do
      let(:csv_data) { parse_csv <<~EOF
        iiif_manifest_url,link_to_institutional_record
        ,
      EOF
      }

      it 'is truthy' do
        expect(validator.validate_urls csv_data.first, 0).to be_truthy
      end
    end
  end

  context 'validate_qids' do

    context "for valid QIDs" do
      it 'is truthy' do
        expect(validator.validate_qids csv_data.first, 0).to be_truthy
      end
    end


    context "for invalid QIDs" do
      let(:csv_data) { parse_csv <<~EOF
        holding_institution_wikidata_qid,other_column
        Qxxx9,val
        ,val
      EOF
      }

      it 'is falsey for invalid QIDs' do
        expect(validator.validate_qids csv_data.first, 0).to be_falsey
      end
    end

  end

  context 'validate_dates' do

    context "for valid Dates" do
      it 'is truthy' do
        expect(validator.validate_dates csv_data.first, 0).to be_truthy
      end
    end

    context "for invalid dates" do
      let(:csv_data) { parse_csv <<~EOF
        record_last_updated,manifest_generated_at
        2023-12-12T05:05:05,2023-31-31T05:05:05
      EOF
      }

      it 'is falsey ' do
        expect(validator.validate_dates csv_data.first, 0).to be_falsey
      end
    end

  end

  context 'validate_source_type' do
    context 'for valid source types' do
      it 'is truthy' do
        expect(validator.validate_source_type manifest.first, 0).to be_truthy
      end
    end

    context 'for unknown source types' do
      let(:csv_data) { parse_csv <<~EOF
        source_data_type,other_column
        BAD SOURCE TYPE,other_value
      EOF
      }
      let(:manifest) { DS::Manifest::Manifest.new csv_data, marc_xml_dir }

      it 'is falsey' do
        expect(validator.validate_source_type manifest.first, 0).to be_falsey
      end
    end

  end

  context 'validate_data_types' do
    it 'returns true for a valid csv' do
      expect(validator.validate_data_types).to be_truthy
    end

    it 'validates URLs' do
      expect(validator).to receive(:validate_urls)
      validator.validate_data_types
    end

    it 'validates QIDs' do
      expect(validator).to receive(:validate_qids)
      validator.validate_data_types
    end

    it 'validates Dates' do
      expect(validator).to receive(:validate_dates)
      validator.validate_data_types
    end
  end

  context 'validate_files_exist' do
    context 'for files that exist' do
      it 'is truthy' do
        expect(validator.validate_files_exist).to be_truthy
      end
    end

    context 'for files that don\'t exist' do
      let(:csv_data) { StringIO.new <<~EOF
        filename,other_column
        not_a_file.xml,val
        EOF
      }

      let(:manifest) { DS::Manifest::Manifest.new csv_data, marc_xml_dir}
      let(:validator) { DS::Manifest::ManifestValidator.new manifest }

      it 'is falsey' do
        expect(validator.validate_files_exist).to be_falsey
      end
    end
  end

  context 'validate_ids' do
    context 'for a CSV with valid IDs' do
      it 'is truthy' do
        expect(validator.validate_ids).to be_truthy
      end
    end

    context 'for a CSV with bad IDs' do
      let(:csv_data) { StringIO.new <<~EOF
        filename,source_data_type,holding_institution_institutional_id,institutional_id_location_in_source
        9951865503503681_marc.xml,MARC XML,XXXXXXXXX,"//marc:controlfield[@tag=""001""]"
      EOF
      }

      let(:manifest) { DS::Manifest::Manifest.new csv_data, marc_xml_dir}
      let(:validator) { DS::Manifest::ManifestValidator.new manifest }

      it 'is falsey' do
        expect(validator.validate_ids).to be_falsey
      end

    end

    context 'validate_ids_unique' do
      context 'ids are unique' do
        it 'is truthy'
      end

      context 'ids are not unique' do
        it 'is falsey'
      end
    end

    context 'validate_records_unique' do
      context "one record per ID" do
        it 'is truthy'
      end
    end
    context 'multiple records for one ID' do
      it 'is falsey'
    end
  end
end