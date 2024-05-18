# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::ReconManager do

  let(:source_type) { DS::Constants::MARC_XML }
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

  context '#write_csv' do
    let(:outfile) { "#{out_dir}/places.csv" }
    before(:each) do
      subject.write_csv Recon::Places
    end

    it 'writes a CSV file' do
      expect(File.exist?(outfile)).to be true
    end
  end

  context '#write_all_csvs' do
    before(:each) do
      subject.write_all_csvs
    end

    it 'writes the places CSV' do
      expect(File.exist?("#{out_dir}/places.csv")).to be true
    end

    it 'writes the genres CSV' do
      expect(File.exist?("#{out_dir}/genres.csv")).to be true
    end

    it 'writes the languages CSV' do
      expect(File.exist?("#{out_dir}/languages.csv")).to be true
    end

    it 'writes the materials CSV' do
      expect(File.exist?("#{out_dir}/materials.csv")).to be true
    end

    it 'writes the named-subjects CSV' do
      expect(File.exist?("#{out_dir}/named-subjects.csv")).to be true
    end

    it 'writes the names CSV' do
      expect(File.exist?("#{out_dir}/names.csv")).to be true
    end

    it 'writes the subjects CSV' do
      expect(File.exist?("#{out_dir}/subjects.csv")).to be true
    end

    it 'writes the titles CSV' do
      expect(File.exist?("#{out_dir}/titles.csv")).to be true
    end
  end
end
