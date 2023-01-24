require 'spec_helper'

describe DS::ImportManifest do

  let(:marc_valid) { fixture_path 'manifest/marc-manifest-valid.csv' }
  let(:marc_extra_col) { fixture_path 'manifest/marc-manifest-extra-column.csv' }
  let(:mets_valid) { fixture_path 'manifest/mets-manifest-valid.csv' }

  context 'validate!' do
    it 'passes a valid manifest' do
      manifest = DS::ImportManifest.new marc_valid
      expect {
        manifest.validate!
      }.not_to raise_error
    end
  end
end