# frozen_string_literal: true

RSpec.shared_examples 'a ReconBuilder' do |skips|

  def skip? *skips, recon_type
    return unless skips.present?
    return unless recon_type.present?
    skips.include? recon_type
  end

  context 'initialize' do
    it 'creates a ReconBuilder' do
      expect(
        Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
      ).to be_a Recon::ReconBuilder
    end
  end

  context "#extract_recons" do

    context ':places', unless: skip_example?(skips, :places) do
      let(:recon_type) { :places }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 3 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':materials', unless: skip_example?(skips, :materials) do
      let(:recon_type) { :materials }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 3 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':languages', unless: skip_example?(skips, :languages) do
      let(:recon_type) { :languages }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 4 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':genres', unless: skip_example?(skips, :genres) do
      let(:recon_type) { :genres }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 4 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':subjects', unless: skip_example?(skips, :subjects) do
      let(:recon_type) { :subjects }

      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 4 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':named-subjects', unless: skip_example?(skips, :'named-subjects') do
      let(:recon_type) { :'named-subjects' }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 6 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':names', unless: skip_example?(skips, :names) do
      let(:recon_type) { :names }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 7 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end

    context ':titles', unless: skip_example?(skips, :titles) do
      let(:recon_type) { :titles }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end

      it 'returns an non-empty array' do
        expect(recon_builder.extract_recons recon_type).not_to be_empty
      end

      let(:number_of_columns) { 5 }
      it 'returns the correct number of elements per row' do
        expect(recon_builder.extract_recons recon_type).to have_columns number_of_columns
      end
    end
  end

end
