require 'spec_helper'

describe Recon do

  let(:data_dir) { fixture_path 'ds-data'  }
  let(:genres_csv) { File.join data_dir, 'terms', 'reconciled', 'genres.csv' }
  let(:languages_csv) { File.join data_dir, 'terms', 'reconciled', 'languages.csv' }
  let(:materials_csv) { File.join data_dir, 'terms', 'reconciled', 'materials.csv' }
  let(:named_subjects_csv) { File.join data_dir, 'terms', 'reconciled', 'named-subjects.csv' }
  let(:names_csv) { File.join data_dir, 'terms', 'reconciled', 'names.csv' }
  let(:places_csv) { File.join data_dir, 'terms', 'reconciled', 'places.csv' }
  let(:subjects_csv) { File.join data_dir, 'terms', 'reconciled', 'subjects.csv' }
  let(:titles_csv) { File.join data_dir, 'terms', 'reconciled', 'titles.csv' }


  context '.lookup' do
    let(:recons_csv) { genres_csv }
    let(:set_name) { :genres }
    let(:subset) { 'somevocab' }
    let(:value) { 'term with .' }
    let(:expected_label) { 'Term With' }
    let(:expected_url) { 'http://vocab.getty.edu/tgn/term-with' }
    let(:expected_ds_qid) { 'Q12345' }

    it 'returns the expected label' do
      expect(Recon.lookup_single set_name, subset: subset, value: value, column: 'authorized_label').to eq expected_label
    end

    it 'returns the expected url' do
      expect(Recon.lookup_single set_name, subset: subset, value: value, column: 'structured_value').to eq expected_url
    end

    it 'returns the expected ds_qid' do
      expect(Recon.lookup_single set_name, subset: subset, value: value, column: 'ds_qid').to eq expected_ds_qid
    end
  end

  context '.load_set' do
    let(:set_name) { :genres }
    let(:recons_csv) { genres_csv }

    before(:each) do
      Recon.load_set set_name
    end

    it 'loads a valid set' do
      expect(Recon.load_set set_name).not_to be_empty
    end

    let(:expected_key) { %q{term with .$$somevocab} }
    it 'includes the expected key' do
      expect(Recon.load_set(set_name)).to include expected_key
    end

    let(:expected_alt_key) { %q{term with$$somevocab} }
    it 'includes the expected alt key' do
      expect(Recon.load_set(set_name)).to include expected_alt_key
    end
  end

  context '.find_set' do
    let(:set_name) { :genres }
    let(:recons_csv) { genres_csv }
    let(:expected_set) { Recon.load_set set_name }

    it 'returns the expect set' do
      expect(Recon.find_set set_name).to eq expected_set
    end
  end

  context '.build_key' do
    let(:value_array) { %w{ Foo Bar} }
    let(:expected_key) { 'foo$$bar' }
    it 'builds a key from an array of values' do
      expect(Recon.build_key value_array).to eq 'foo$$bar'
    end
  end

  context '.build_alt_key' do
    let(:key) { 'foo.$$bar' }
    let(:expected_alt_key) { 'foo$$bar' }
    it 'builds a key' do
      expect(Recon.build_alt_key key).to eq expected_alt_key
    end
  end

  context '.read_csv' do
    let(:recons_csv) { genres_csv }

    it 'reads a CSV' do
      expect(
        Recon.read_csv csv_file: recons_csv,
                       recon_type: Recon::Type::Genres,
                       data: {}
      ).not_to be_empty
    end
  end

  context '.validate!' do

    let(:valid_names_csv) { fixture_path 'names-valid.csv' }
    let(:invalid_names_csv) { fixture_path 'names-bad-columns.csv' }
    let(:valid_genres_csv) { fixture_path 'genres-valid.csv'}
    let(:invalid_genres_csv) { fixture_path 'genres-bad-columns.csv' }
    let(:invalid_genres_splits_csv) { fixture_path 'genres-bad-splits.csv' }

    it 'passes a valid names CSV' do
      expect {
        Recon.validate! :names, valid_names_csv
      }.not_to raise_error
    end

    it 'fails a names CSV missing headers' do
      expect {
        Recon.validate! :names, invalid_names_csv
      }.to raise_error /name_as_recorded.*instance_of.*authorized_label.*structured_value.*ds_qid/
    end

    it 'passes a valid genres CSV' do
      expect {
        Recon.validate! :genres, valid_genres_csv
      }.not_to raise_error
    end

    it 'fails a genres CSV missing headers' do
      expect {
        Recon.validate! :genres, invalid_genres_csv
      }.to raise_error /genre_as_recorded.*vocabulary.*authorized_label.*structured_value.*ds_qid/
    end
  end

end
