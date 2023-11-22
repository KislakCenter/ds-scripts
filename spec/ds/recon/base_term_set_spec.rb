# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::BaseTermSet do

  class TestSet < Recon::BaseTermSet; end

  context 'new' do
    let(:term_set_config) {
      {
        name:                    "test_set",
        csv_path:                "recon/test_set_with_subset.csv",
        key_column:              "term_as_recorded",
        subset_column:           "vocabulary",
        structured_data_column:  "structured_value",
        authorized_label_column: "authorized_label",
        balanced_columns:         %w{structured_value authorized_label}
      }
    }

    it 'creates a new BaseTermSet instance' do
      expect(TestSet.new(**term_set_config)).to be_a Recon::BaseTermSet
    end
  end

  context 'terms without a subset' do
    let(:terms_csv) {
      fixture_path 'recon/test_set.csv'
    }

    let(:term_set_config) {
      {
        name:                    "a_term_set",
        csv_path:                terms_csv,
        key_column:              "term_as_recorded",
        structured_data_column:  "structured_value",
        authorized_label_column: "authorized_label",
        balanced_columns:        %w{structured_value authorized_label}
      }
    }

    let(:term_set) { TestSet.new **term_set_config }

    context "load_set" do
      it 'successfully loads source data' do
        expect {
          term_set.load_set terms_csv
        }.not_to raise_error
      end

    end

    context 'build_key' do
      it 'builds a key' do
        expect(
          term_set.build_key term: 'term', subset: 'sub'
        ).to eq "term$$sub"
      end
    end

    context 'lookup' do
      before :each do
        term_set.load_set terms_csv
      end

      it 'looks up a label' do
        expect(
          term_set.lookup(
            as_recorded:   "Some Term",
            return_column: 'authorized_label'
          )
        ).to eq "A label"
      end

      it 'looks up a structured value' do
        expect(
          term_set.lookup(
            as_recorded:   "Some Term",
            return_column: 'structured_value'
          )
        ).to eq 'some_id'
      end
    end
  end

  context 'terms with a subset' do
      let(:terms_csv) {
        fixture_path 'recon/test_set_with_subset.csv'
      }

      let(:term_set_config) {
        {
          name:                    "terms_with_subset",
          csv_path:                terms_csv,
          key_column:              "term_as_recorded",
          subset_column:           "vocabulary",
          structured_data_column:  "structured_value",
          authorized_label_column: "authorized_label",
          balanced_columns:        %w{structured_value authorized_label}
        }
      }

      let(:term_set) { TestSet.new **term_set_config }

      context "load_set" do
        it 'successfully loads source data' do
          expect {
            term_set.load_set terms_csv
          }.not_to raise_error
        end

      end

      context 'build_key' do
        it 'builds a key' do
          expect(
            term_set.build_key term: 'term', subset: 'sub'
          ).to eq "term$$sub"
        end
      end

      context 'lookup' do
        before :each do
          term_set.load_set terms_csv
        end

        it 'looks up a label' do
          expect(
            term_set.lookup(
              as_recorded:   "Some Term",
              return_column: 'authorized_label',
              subset:        'some_subset'
            )
          ).to eq "some term"
        end

        it 'looks up a structured value' do
          expect(
            term_set.lookup(
              as_recorded:   "Some Term",
              return_column: 'structured_value',
              subset:        'some_subset'
            )
          ).to eq 'http://example.com'
        end
      end
  end # terms with a subset

  context 'terms without structure_values' do
    let(:terms_csv) {
      fixture_path 'recon/test_set_without_structured_values.csv'
    }

    let(:term_set_config) {
      {
        name:                    "terms_without_structured_values",
        csv_path:                terms_csv,
        key_column:              "title_as_recorded",
        authorized_label_column: "authorized_label",
        balanced_columns:        %w{structured_value authorized_label}
      }
    }

    let(:term_set) { TestSet.new **term_set_config }

    context "load_set" do
      it 'successfully loads source data' do
        expect {
          term_set.load_set terms_csv
        }.not_to raise_error
      end

    end

    context 'build_key' do
      it 'builds a key' do
        expect(
          term_set.build_key term: 'term', subset: 'sub'
        ).to eq "term$$sub"
      end
    end

    context 'lookup' do
      before :each do
        term_set.load_set terms_csv
      end

      it 'looks up a label' do
        expect(
          term_set.lookup(
            as_recorded:   "A title",
            return_column: 'authorized_label'
          )
        ).to eq "A Title"
      end

      it 'looks up a structured value' do
        expect(
          term_set.lookup(
            as_recorded:   "A title",
            return_column: 'structured_value'
          )
        ).to be_nil
      end
    end
  end # terms with a subset
end