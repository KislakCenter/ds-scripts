# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Util::CsvValidator do

  let(:balanced_columns) {
    { group1: [:a, :b] }
  }

  let(:valid_row) {
    { a: 'a|a;a', b: 'b|b;b'}
  }

  let(:nested_columns) {
    { b: :b_group }
  }

  context '.validate_row' do

    it 'returns no errors for a valid row' do
      expect(described_class.validate_row(valid_row)).to be_empty
    end
  end


  context '.validate_balanced_columns' do
    it 'returns no errors for a valid row' do
      expect(described_class.validate_balanced_columns(valid_row, balanced_columns: balanced_columns)).to be_empty
    end

    let(:invalid_row) {
      { a: 'a', b: 'b|b' }
    }

    it "returns errors for an invalid row" do
      expect(described_class.validate_balanced_columns(invalid_row, balanced_columns: balanced_columns).size).to eq 1
    end

    it 'has the expected errors' do
      expect(described_class.validate_balanced_columns(invalid_row, balanced_columns: balanced_columns)).to include /group: :group1/
    end

    context "allow_blank: false|true" do
      let(:row_with_blank_subfield) {
        { a: 'a|b', b: 'b|' }
      }

      it 'returns errors for a row with blank subfields when allow_blank: false' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, balanced_columns: balanced_columns, allow_blank: false
          ).size
        ).to eq 1
      end

      it 'returns errors for a row with blank subfields when allow_blank is not set' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, balanced_columns: balanced_columns
          ).size
        ).to eq 1
      end

      it 'returns the expected error when allow_blank: false' do
        expected = [/#{DS::Util::CsvValidator::ERROR_BLANK_SUBFIELDS}: group: :group1/]
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, balanced_columns: balanced_columns, allow_blank: false
          )
        ).to match expected
      end

      it 'returns no errors for a row with blank subfields when allow_blank: true' do
        expect(
          described_class.validate_balanced_columns(
            row_with_blank_subfield, balanced_columns: balanced_columns, allow_blank: true
          )
        ).to be_empty
      end
    end
  end


  context '.validate_row_splits' do
    let(:valid_values) { valid_row.values }

    it 'returns no errors for a valid row' do
      expect(described_class.validate_row_splits(row_values: valid_values)).to be_empty
    end

    let(:invalid_row) {
      { a: 'a', b: 'b|b' }
    }

    let(:invalid_values) { invalid_row.values }

    it 'returns no errors for a valid row' do
      expect(described_class.validate_row_splits(row_values: invalid_values).size).to eq 1
    end

    it 'has the expected errors' do
      expected = [/#{DS::Util::CsvValidator::ERROR_UNBALANCED_SUBFIELDS}/]
      expect(described_class.validate_row_splits(row_values: invalid_values)).to match expected
    end

  end

  context ".validate_required_columns" do
    let(:required_columns) { [:a, :b] }
    it 'returns no errors for a valid row' do
      expect(described_class.validate_required_columns(valid_row, required_columns)).to be_blank
    end

    let(:invalid_row) {
      { a: 'a|a', c: 'c|c' }
    }

    it 'returns errors for an invalid row' do
      expect(described_class.validate_required_columns(invalid_row, required_columns)).not_to be_blank
    end

    it 'has the expected errors' do
      expected = ["#{DS::Util::CsvValidator::ERROR_MISSING_REQUIRED_COLUMNS}: b"]
      expect(described_class.validate_required_columns(invalid_row, required_columns)).to eq expected
    end
  end

  context '.validate_whitespace' do
    context 'with no nested columns' do

      it 'returns no errors for a valid row' do
        expect(described_class.validate_whitespace(valid_row)).to be_empty
      end

      let(:invalid_row) {
        { a: 'a', b: 'b |b ;b', c: 'c', d: 'd ' }
      }

      it 'returns errors for a invalid row' do
        expect(described_class.validate_whitespace(invalid_row).size).to eq 2
      end

      it 'has the expected errors' do
        expected = [/column b/, /column d/]
        expect(described_class.validate_whitespace(invalid_row)).to match expected
      end

      context 'with nested columns' do
        let(:invalid_row) {
          { a: 'a', b: 'b|b ;b', c: 'c', d: 'd' }
        }

        let(:nested_columns) {
          { b: :b_group }
        }

        it 'returns no errors for a valid row' do
          expect(described_class.validate_whitespace(valid_row, nested_columns: nested_columns)).to be_empty
        end


        it 'returns errors for a invalid row' do
          expect(described_class.validate_whitespace(invalid_row, nested_columns: nested_columns).size).to eq 1
        end

        it 'has the expected errors' do
          expected = [/b_group.*column b/]
          expect(described_class.validate_whitespace(invalid_row, nested_columns: nested_columns)).to match expected
        end
      end
    end



  end
end
