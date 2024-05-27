# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Util::CsvValidator do

  context ".validate_all_rows" do
    let(:valid_rows) {
      [
        { a: 'a', b: 'b' }, { a: 'x', b: 'y' }
      ]
    }

    it 'returns no errors for a valid row' do
      expect(described_class.validate_all_rows(valid_rows)).to be_empty
    end

    context 'with required column missing' do
      let(:invalid_rows) { [{ a: 'a', b: 'b' }, { a: 'x', b: 'y' }] }
      let(:required_columns) { %i{ a x } }
      let(:expected_error) {
        /CSV is missing required column\(s\): x.*row \d/
      }
      let(:errors) {
        described_class.validate_all_rows(invalid_rows, required_columns: required_columns)
      }
      it "returns 1 error" do
        expect(errors.size).to eq 1
      end

      it 'returns the expected error' do
        expect(errors.first).to match(expected_error)
      end
    end

    context 'multiple errors' do
      let(:invalid_rows) { [{ a: 'a|a', b: 'b' }, { a: 'x', b: 'y|y' }] }
      let(:balanced_columns) {
        { group1: %i{ a b } }
      }
      let(:expected_errors) {
        [
          /Row has subfields of different lengths.*row \d/,
          /Row has subfields of different lengths.*row \d/,
        ]
      }

      let(:errors) {
        described_class.validate_all_rows(invalid_rows, balanced_columns: balanced_columns)
      }
      it "returns 2 errors" do
        expect(errors.size).to eq 2
      end

      it "returns the expected errors" do
        expect(errors).to match_array(expected_errors)
      end
    end
  end

  context '.validate_row' do

    let(:valid_row) {
      { a: 'a|a;a', b: 'b|b;b' }
    }

    let(:nested_columns) {
      { b: :b_group }
    }

    context 'with default parameters' do
      it 'returns no errors for a valid row' do
        expect(described_class.validate_row(valid_row, row_num: 1)).to be_empty
      end
    end

    context 'with required column missing' do
      let(:invalid_row) {
        { a: 'a|a;a', b: 'b|b;b' }
      }
      let(:required_columns) {
        %i{ a x }
      }

      it 'returns an error for a missing required column' do
        expect(
          described_class.validate_row(invalid_row, row_num: 1, required_columns: required_columns).size
        ).to eq 1
      end

      it 'halts validation when a required column is missing' do
        allow(described_class).to receive(:validate_balanced_columns).and_return(['error'])
        allow(described_class).to receive(:validate_whitespace).and_return(['error'])
        described_class.validate_row(invalid_row, row_num: 1, required_columns: required_columns)

        expect(described_class).not_to have_received(:validate_balanced_columns)
        expect(described_class).not_to have_received(:validate_whitespace)
      end

      let(:expected_error) {
        [/CSV is missing required column\(s\): x.*row \d+/]
      }
      it "returns an error with the row number" do
        expect(described_class.validate_row(invalid_row, row_num: 1, required_columns: required_columns)).to match(expected_error)
      end
    end

    context 'with balanced_columns set' do
      context "without nested_columns set" do
        let(:valid_row) {
          { a: 'a|aa', b: 'b|bb' }
        }

        let(:balanced_columns) {
          { group1: [:a, :b] }
        }

        let(:invalid_row) {
          { a: 'a', b: 'b|b' }
        }

        it 'returns no errors for a valid row' do
          expect(described_class.validate_row(valid_row, row_num: 1, balanced_columns: balanced_columns)).to be_empty
        end

        let(:errors) {
          described_class.validate_row(invalid_row, row_num: 1, balanced_columns: balanced_columns)
        }

        let(:expected_error) {
          [/Row has subfields of different lengths: group: :group1, sizes:.*row \d+/]
        }

        it "returns 1 error" do
          expect(errors.size).to eq 1
        end

        it "returns the expected error" do
          expect(errors).to match expected_error
        end
      end

      context "with nested_columns set" do
        let(:balanced_columns) {
          { group1: [:a, :b] }
        }

        let(:nested_columns) {
          { a: :group1, b: :group1 }
        }

        let(:valid_row) {
          { a: 'a|a;a', b: 'b|b;b' }
        }

        let(:invalid_row) {
          { a: 'a|a', b: 'b|b;b' }
        }

        it 'returns no errors for a valid row' do
          expect(
            described_class.validate_row(
              valid_row, row_num: 1, balanced_columns: balanced_columns, nested_columns: nested_columns
            )
          ).to be_empty
        end

        let(:expected_error) {
          [/Row has subfields of different lengths: group: :group1, sizes:.*row \d/]
        }
        let(:errors) {
          described_class.validate_row(
            invalid_row, row_num: 1, balanced_columns: balanced_columns, nested_columns: nested_columns
          )
        }

        it 'has one error' do
          expect(errors.size).to eq 1
        end

        it 'has the expected error' do
          expect(errors).to match expected_error
        end
      end
    end

    context 'with whitespace errors' do
      let(:valid_row) {
        { a: 'a|a;a', b: 'b|b;b' }
      }
      it 'returns no errors for a valid row' do
        expect(described_class.validate_row(valid_row, row_num: 1)).to be_empty
      end

      let(:invalid_row) {
        { a: 'a|a', b: 'b|b;b', d: 'd ' }
      }
      let(:errors) { described_class.validate_row(invalid_row, row_num: 1) }
      let(:expected_error) {
        [/Row contains trailing whitespace.*row \d/]
      }

      it 'returns one error' do
        expect(errors.size).to eq 1
      end

      it 'returns the expected error' do
        expect(errors).to match expected_error
      end
    end

    context 'multiple errors' do
      let(:balanced_columns) {
        { group1: [:a, :b] }
      }
      let(:invalid_row) {
        { a: 'a|a', b: 'b', d: 'd ' }
      }

      let(:errors) { described_class.validate_row(invalid_row, row_num: 1, balanced_columns: balanced_columns) }
      it 'returns multiple errors' do
        expect(errors.size).to eq 2
      end

      let(:expected_errors) {
        [
          /Row has subfields of different lengths.*row \d/,
          /Row contains trailing whitespace.*row \d/
        ]
      }

      it 'returns the expected errors' do
        expect(errors).to match expected_errors
      end
    end

  end

  context '.validate_balanced_columns' do
    let(:balanced_columns) {
      { group1: [:a, :b] }
    }
    let(:valid_row) {
      { a: 'a|a', b: 'b|b' }
    }
    it 'returns no errors for a valid row' do
      expect(described_class.validate_balanced_columns(valid_row, row_num: 1, balanced_columns: balanced_columns)).to be_empty
    end

    let(:invalid_row) {
      { a: 'a', b: 'b|b' }
    }

    it "returns errors for an invalid row" do
      expect(described_class.validate_balanced_columns(invalid_row, row_num: 1, balanced_columns: balanced_columns).size).to eq 1
    end

    it 'has the expected errors' do
      expect(described_class.validate_balanced_columns(invalid_row, row_num: 1, balanced_columns: balanced_columns)).to include /group: :group1/
    end

    context "allow_blank: false|true" do
      let(:row_with_blank_subfield) {
        { a: 'a|b', b: 'b|' }
      }

      it 'returns errors for a row with blank subfields when allow_blank: false' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, row_num: 1, balanced_columns: balanced_columns, allow_blank: false
          ).size
        ).to eq 1
      end

      it 'returns errors for a row with blank subfields when allow_blank is not set' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, row_num: 1, balanced_columns: balanced_columns
          ).size
        ).to eq 1
      end

      let(:expected_error) {
        [/#{DS::Util::CsvValidator::ERROR_BLANK_SUBFIELDS}: group: :group1.*row \d/]
      }
      it 'returns the expected error when allow_blank: false' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, row_num: 1, balanced_columns: balanced_columns, allow_blank: false
          )
        ).to match expected_error
      end

      it 'returns no errors for a row with blank subfields when allow_blank: true' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, row_num: 1, balanced_columns: balanced_columns, allow_blank: true
          )
        ).to be_empty
      end
    end
  end

  context '.validate_row_splits' do
    let(:valid_row) { { a: 'a|a;a', b: 'b|b;b' } }
    let(:valid_values) { valid_row.values }

    it 'returns no errors for a valid row' do
      expect(described_class.validate_row_splits(row_values: valid_values, row_num: 1)).to be_empty
    end

    it 'returns no errors for a valid row' do
      expect(described_class.validate_row_splits(row_values: invalid_values, row_num: 1).size).to eq 1
    end

    let(:invalid_row) { { a: 'a', b: 'b|b' } }
    let(:invalid_values) { invalid_row.values }
    let(:expected_error) { [/Row has subfields of different lengths.*row \d/] }

    it 'has the expected errors' do
      expect(described_class.validate_row_splits(row_values: invalid_values, row_num: 1)).to match expected_error
    end

    context 'with missing columns' do
      let(:valid_values) { [nil,nil] }

      it "returns no errors when both values are nil" do
        expect(described_class.validate_row_splits(row_values: valid_values, row_num: 1)).to be_empty
      end

      let(:nil_and_non_nil_values) { [nil, 'a'] }

      it "returns no errors when one value is nil and the other has no subfields" do
        expect(described_class.validate_row_splits(row_values: nil_and_non_nil_values, row_num: 1)).to be_blank
      end

      let(:nil_and_subfield_values) { [nil, 'a|a'] }
      let(:expected_error) { [/Row has subfields of different lengths.*row \d/] }
      let(:errors) {
        described_class.validate_row_splits(row_values: nil_and_subfield_values, row_num: 1)
      }

      it "returns 1 error when one values is nil and the other has subfields" do
        expect(errors.size).to eq 1
      end

      it "returns the expected error" do
        expect(errors).to match expected_error
      end
    end

  end

  context ".validate_required_columns" do

    let(:valid_row) { { a: 'a', b: 'b' } }
    let(:required_columns) { [:a, :b] }

    it 'returns no errors for a valid row' do
      expect(described_class.validate_required_columns(valid_row, row_num: 1, required_columns: required_columns)).to be_blank
    end

    let(:invalid_row) { { a: 'a|a', c: 'c|c' } }

    it 'returns errors for an invalid row' do
      expect(described_class.validate_required_columns(invalid_row, row_num: 1, required_columns: required_columns)).not_to be_blank
    end

    let(:expected_error) {
      [/CSV is missing required column\(s\): b.*row \d/]
    }
    it 'has the expected errors' do
      expect(described_class.validate_required_columns(invalid_row, row_num: 1, required_columns: required_columns)).to match expected_error
    end
  end

  context '.validate_whitespace' do
    let(:valid_row) {
      { a: 'a', b: 'b|b;b', c: 'c', d: 'd' }
    }
    context 'with :nested_columns unset' do


      it 'returns no errors for a valid row' do
        expect(described_class.validate_whitespace(valid_row, row_num: 1)).to be_empty
      end

      let(:invalid_row) {
        { a: 'a', b: 'b |b ;b', c: 'c', d: 'd ' }
      }

      it 'returns errors for a invalid row' do
        expect(described_class.validate_whitespace(invalid_row, row_num: 1).size).to eq 2
      end

      let(:expected_error) {
        [/column :b.*row \d/, /column :d.*row \d/]
      }
      it 'has the expected errors' do
        expect(described_class.validate_whitespace(invalid_row, row_num: 1)).to match expected_error
      end
    end

    context 'with :nested_columns set' do
      let(:invalid_row) {
        { a: 'a', b: 'b|b ;b', c: 'c', d: 'd' }
      }

      let(:nested_columns) {
        { b: :group1, a: :group1 }
      }

      it 'returns no errors for a valid row' do
        expect(described_class.validate_whitespace(valid_row, row_num: 1, nested_columns: nested_columns)).to be_empty
      end

      it 'returns errors for a invalid row' do
        expect(described_class.validate_whitespace(invalid_row, row_num: 1, nested_columns: nested_columns).size).to eq 1
      end
      let(:expected_error) {
        [/group: :group1.*column :b.*row \d/]
      }
      it 'has the expected errors' do
        expect(described_class.validate_whitespace(invalid_row, row_num: 1, nested_columns: nested_columns)).to match expected_error
      end
    end

  end
end
