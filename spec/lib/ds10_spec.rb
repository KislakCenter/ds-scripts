require 'spec_helper'
require 'nokogiri'

describe DS::DS10 do

  # let(:na_ds_mets) {̋̋ fixture_path 'ds_mets-nelson-atkins-kg40.xml' }
  let(:na_ds_mets) { fixture_path 'ds_mets-nelson-atkins-kg40.xml' }

  let(:na_ds_xml) {
    File.open(na_ds_mets) { |f| Nokogiri::XML f }
  }

  let(:nd_ds_ms) { DS::DS10.find_ms na_ds_xml }


  context 'extract_ms_notes' do
    it 'finds an untyped note' do
      expect(DS::DS10.extract_ms_notes na_ds_xml).to include 'Manuscript note: Untyped note'
    end

    it 'finds a bibliography note' do
      expect(DS::DS10.extract_ms_notes na_ds_xml).to include 'Bibliography: Bibliography'
    end

    it 'finds a source note note' do
      expect(DS::DS10.extract_ms_notes na_ds_xml).to include 'Source note: source note'
    end
  end

  context 'extract_part_note' do
    it 'finds an untyped note' do
      expect(DS::DS10.extract_part_note na_ds_xml).to include 'One leaf: Untyped part note'
    end
  end

  context 'extract_text_note' do
    it 'finds an untyped note' do
      expect(DS::DS10.extract_text_note na_ds_xml).to include 'One leaf: Untyped text note'
    end
  end

  context 'extract_page_note' do
    it 'finds an untyped note' do
      expect(DS::DS10.extract_page_note na_ds_xml).to include 'f. 1r: Untyped page note'
    end
  end
end