# frozen_string_literal: true

RSpec.shared_examples "a manifest validator" do
  context '.initialize' do
    it 'creates a new ManifestValidator ' do
      expect(DS::Manifest::ManifestValidator.new manifest).to be_a DS::Manifest::ManifestValidator
    end
  end

  context 'valid?' do
    it 'is valid' do
      expect(validator.valid?).to be_truthy
    end


  end

  context 'validate_columns' do
    context 'with valid columns' do
      it 'is truthy' do
        expect(validator.validate_columns).to be_truthy
      end
    end
  end

end
