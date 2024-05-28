# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::ReconManager do

  let(:source_type) { DS::Constants::MARC_XML }
  let(:tmpdir) { ENV['TMPDIR'] || '/tmp' }
  let(:out_dir) { File.join(tmpdir, "ReconManagerSpec#$$") }
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

  before(:each) do
    FileUtils.mkdir out_dir
  end

  after(:each) do
    FileUtils.rm_rf out_dir
  end

  context '#initialize' do
    it 'is a ReconManager' do
      expect(
        Recon::ReconManager.new(
          recon_builder: recon_builder, out_dir: out_dir
        )
      ).to be_a Recon::ReconManager
    end
  end

  context '#write_csv' do
    let(:outfile) { "#{out_dir}/places.csv" }
    before(:each) do
      subject.write_csv Recon::Places, outfile
    end

    it 'writes a CSV file' do
      expect(File.exist?(outfile)).to be true
    end
  end

  context '#write_all_csvs' do
    before(:each) do
      subject.write_all_csvs
    end

    # doing all these in one block to cut down on file system churn
    it 'writes the CSVs' do
      expect(File.exist?("#{out_dir}/places.csv")).to be true
      expect(File.exist?("#{out_dir}/genres.csv")).to be true
      expect(File.exist?("#{out_dir}/languages.csv")).to be true
      expect(File.exist?("#{out_dir}/materials.csv")).to be true
      expect(File.exist?("#{out_dir}/named-subjects.csv")).to be true
      expect(File.exist?("#{out_dir}/names.csv")).to be true
      expect(File.exist?("#{out_dir}/subjects.csv")).to be true
      expect(File.exist?("#{out_dir}/titles.csv")).to be true
    end
  end
end
