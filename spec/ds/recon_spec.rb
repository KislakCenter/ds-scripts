require 'spec_helper'

describe 'Recon' do

  let(:valid_names_csv) { fixture_path 'names-valid.csv' }

  let(:invalid_names_csv) { fixture_path 'names-bad-columns.csv' }

  let(:valid_genres_csv) { fixture_path 'genres-valid.csv'}

  let(:invalid_genres_csv) { fixture_path 'genres-bad-columns.csv' }

  let(:invalid_genres_splits_csv) { fixture_path 'genres-bad-splits.csv' }

  context 'validate!' do
    it 'passes a valid names CSV' do
      expect {
        Recon.validate! :names, valid_names_csv
      }.not_to raise_error
    end

    it 'fails a names CSV missing headers' do
      expect {
        Recon.validate! :names, invalid_names_csv
      }.to raise_error /name_as_recorded, instance_of, authorized_label, structured_value, ds_qid/
    end

    it 'passes a valid genres CSV' do
      expect {
        Recon.validate! :genres, valid_genres_csv
      }.not_to raise_error
    end

    it 'fails a genres CSV missing headers' do
      expect {
        Recon.validate! :genres, invalid_genres_csv
      }.to raise_error /genre_as_recorded, vocabulary, authorized_label, structured_value, ds_qid/
    end
  end
end
