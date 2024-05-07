# frozen_string_literal: true
RSpec.shared_examples "a recon extractor" do |options|

  it 'responds to extract_places' do
    expect(described_class).to respond_to :extract_places
  end

  it 'responds to extract_materials' do
    expect(described_class).to respond_to :extract_materials
  end

  it 'responds to extract_authors' do
    expect(described_class).to respond_to :extract_authors
  end

  it 'responds to extract_artists' do
    expect(described_class).to respond_to :extract_artists
  end

  it 'responds to extract_scribes' do
    expect(described_class).to respond_to :extract_scribes
  end

  it 'responds to extract_former_owners' do
    expect(described_class).to respond_to :extract_former_owners
  end

  it 'responds to extract_genres', unless: skip?(options, :skip_genres) do
    expect(described_class).to respond_to :extract_genres
  end

  it 'responds to extract_subjects' do
    expect(described_class).to respond_to :extract_subjects
  end

  it 'responds to extract_named_subjects', unless: skip?(options, :skip_named_subjects) do
    expect(described_class).to respond_to :extract_named_subjects
  end

  it 'responds to extract_titles' do
    expect(described_class).to respond_to :extract_titles
  end

  it 'responds to extract_languages' do
    expect(described_class).to respond_to :extract_languages
  end


end
