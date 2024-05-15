# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::ReconManager do

  let(:source_type) { DS::Constants::TEI_XML }
  let(:out_dir) { ENV['TMPDIR'] || '/tmp' }
  let(:files) {
    "#{fixture_path 'marc_xml'}/9951865503503681_marc.xml"
  }

  let(:recon_builder ) {
    Recon::ReconBuilder.new(
      out_dir: out_dir, source_type: source_type, files: files
    )
  }

  let(:subject) {
    described_class.new recon_builder: recon_builder, out_dir: out_dir
  }

  context '#initialize' do
    it 'is a ReconManager' do
      expect(
        Recon::ReconManager.new(
          recon_builder: recon_builder, out_dir: out_dir
        )
      ).to be_a Recon::ReconManager
    end
  end
end
