require 'rspec'

describe 'Recon' do

  let(:names_config) {
    {
      'name'                   => 'names',
      'repo_path'              => 'terms/names.csv',
      'key_column'             => 'name_as_recorded',
      'structured_data_column' => 'structured_value'
    }
  }

  let(:genres_config) {
    {
      'name'                   => 'genres',
      'repo_path'              => 'terms/genres.csv',
      'key_column'             => 'genre_as_recorded',
      'subset_column'          => 'vocabulary',
      'structured_data_column' => 'structured_value'
    }
  }

  let(:valid_names_csv) { fixture_path 'names-valid.csv' }

  let(:invalid_names_csv) { fixture_path 'names-bad-columns.csv' }

  let(:valid_genres_csv) { fixture_path 'genres-valid.csv'}

  let(:invalid_genres_csv) { fixture_path 'genres-bad-columns.csv' }

  context 'validate!' do
    it 'passes a valid names CSV' do
      expect {
        Recon.validate! names_config, valid_names_csv
      }.not_to raise_error
    end

    it 'fails a names CSV missing headers' do
      expect {
        Recon.validate! names_config, invalid_names_csv
      }.to raise_error /name_as_recorded, structured_value/
    end

    it 'passes a valid genres CSV' do
      expect {
        Recon.validate! genres_config, valid_genres_csv
      }.not_to raise_error
    end

    it 'fails a genres CSV missing headers' do
      expect {
        Recon.validate! genres_config, invalid_genres_csv
      }.to raise_error /genre_as_recorded, structured_value, vocabulary/
    end
  end
end