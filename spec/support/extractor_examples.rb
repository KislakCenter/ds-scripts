# frozen_string_literal: true

RSpec.shared_examples "an extractor" do

  it 'responds to extract_cataloging_convention' do
    expect(described_class).to respond_to :extract_cataloging_convention
  end
  it 'responds to extract_cataloging_convention' do
    expect(described_class).to respond_to :extract_cataloging_convention
  end

  it 'responds to extract_titles_as_recorded' do
    expect(described_class).to respond_to :extract_titles_as_recorded
  end

  it 'responds to extract_titles_as_recorded_agr' do
    expect(described_class).to respond_to :extract_titles_as_recorded_agr
  end

  it 'responds to extract_uniform_titles_as_recorded' do
    expect(described_class).to respond_to :extract_uniform_titles_as_recorded
  end

  it 'responds to extract_uniform_titles_as_recorded_agr' do
    expect(described_class).to respond_to :extract_uniform_titles_as_recorded_agr
  end

  it 'responds to extract_recon_titles' do
    expect(described_class).to respond_to :extract_recon_titles
  end

  it 'responds to extract_production_date_as_recorded' do
    expect(described_class).to respond_to :extract_production_date_as_recorded
  end

  it 'responds to extract_date_range' do
    expect(described_class).to respond_to :extract_date_range
  end

  it 'responds to extract_production_places_as_recorded' do
    expect(described_class).to respond_to :extract_production_places_as_recorded
  end

  it 'responds to extract_recon_places' do
    expect(described_class).to respond_to :extract_recon_places
  end

  it 'responds to extract_language_as_recorded' do
    expect(described_class).to respond_to :extract_language_as_recorded
  end

  it 'responds to extract_authors_as_recorded' do
    expect(described_class).to respond_to :extract_authors_as_recorded
  end

  it 'responds to extract_authors_as_recorded_agr' do
    expect(described_class).to respond_to :extract_authors_as_recorded_agr
  end

  it 'responds to extract_artists_as_recorded' do
    expect(described_class).to respond_to :extract_artists_as_recorded
  end

  it 'responds to extract_artists_as_recorded_agr' do
    expect(described_class).to respond_to :extract_artists_as_recorded_agr
  end

  it 'responds to extract_scribes_as_recorded' do
    expect(described_class).to respond_to :extract_scribes_as_recorded
  end

  it 'responds to extract_scribes_as_recorded_agr' do
    expect(described_class).to respond_to :extract_scribes_as_recorded_agr
  end

  it 'responds to extract_former_owner_as_recorded' do
    expect(described_class).to respond_to :extract_former_owners_as_recorded
  end

  it 'responds to extract_former_owner_as_recorded_agr' do
    expect(described_class).to respond_to :extract_former_owners_as_recorded_agr
  end

  it 'responds to extract_recon_names' do
    expect(described_class).to respond_to :extract_recon_names
  end

  it 'responds to extract_physical_description' do
    expect(described_class).to respond_to :extract_physical_description
  end

  it 'responds to extract_materials_as_recorded' do
    expect(described_class).to respond_to :extract_materials_as_recorded
  end


  it 'responds to extract_subjects_as_recorded' do
    expect(described_class).to respond_to :extract_scribes_as_recorded
  end

  it 'responds to extract_named_subjects_as_recorded' do
    expect(described_class).to respond_to :extract_named_subjects_as_recorded
  end

  it 'responds to extract_recon_subjects' do
    expect(described_class).to respond_to :extract_recon_subjects
  end

  it 'responds to extract_genres_as_recorded' do
    expect(described_class).to respond_to :extract_genres_as_recorded
  end

  it 'responds to extract_recon_genres' do
    expect(described_class).to respond_to :extract_recon_genres
  end

  it 'responds to extract_notes' do
    expect(described_class).to respond_to :extract_notes
  end

  it 'responds to extract_date_source_modified' do
    expect(described_class).to respond_to :extract_date_source_modified
  end

  it 'responds to extract_acknowledgments' do
    expect(described_class).to respond_to :extract_acknowledgments
  end

end
