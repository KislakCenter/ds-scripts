# frozen_string_literal: true

RSpec.shared_examples "an extractor with AGR methods" do |options|

  context 'extract_titles_as_recorded_agr' do
    let(:extract_method) { :extract_titles_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_uniform_titles_as_recorded_agr' do
    let(:extract_method) { :extract_uniform_titles_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_authors_as_recorded_agr' do
    let(:extract_method) { :extract_authors_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_artists_as_recorded_agr' do
    let(:extract_method) { :extract_artists_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_scribes_as_recorded_agr' do
    let(:extract_method) { :extract_scribes_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end

  context 'extract_former_owners_as_recorded_agr' do
    let(:extract_method) { :extract_former_owners_as_recorded_agr }
    let(:return_type) { Array }

    it 'responds to the method' do
      expect(described_class).to respond_to extract_method
    end

    it 'returns the expected type' do
      expect(described_class.send extract_method, record).to be_a return_type
    end
  end
end
