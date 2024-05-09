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

    context ':places', unless: skip?(skips, :places) do
      let(:recon_type) { :places }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':materials', unless: skip?(skips, :materials) do
      let(:recon_type) { :materials }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':languages', unless: skip?(skips, :languages) do
      let(:recon_type) { :languages }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':genres', unless: skip?(skips, :genres) do
      let(:recon_type) { :genres }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':subjects', unless: skip?(skips, :subjects) do
      let(:recon_type) { :subjects }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':named-subjects', unless: skip?(skips, :'named-subjects') do
      let(:recon_type) { :'named-subjects' }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':names', unless: skip?(skips, :names) do
      let(:recon_type) { :names }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end

    context ':titles', unless: skip?(skips, :titles) do
      let(:recon_type) { :titles }
      it 'returns an array' do
        expect(recon_builder.extract_recons recon_type).to be_an Array
      end
    end
  end

end
