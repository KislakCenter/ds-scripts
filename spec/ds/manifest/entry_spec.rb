# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::Entry' do

  let(:manifest_csv) {
    parse_csv(<<~EOF
      holding_institution_ds_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,dated,holding_institution_institutional_id,record_lookup_value,lookup_value_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
      Q49117,9951865503503681_marc.xml,University of Pennsylvania,marc-xml,DS10000,true,9951865503503681,9951865503503681,"controlfield[@tag='001']/text()",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
    EOF
  )
 }
  let(:marc_xml_dir) { fixture_path 'marc_xml' }

  let(:manifest) {
    DS::Manifest::Manifest.new manifest_path, marc_xml_dir
  }
  let(:manifest_row) { manifest_csv.first }


  let(:entry) { DS::Manifest::Entry.new manifest_row }

  context 'initialize' do
    it 'creates a new DS::Manifest::Entry' do
      expect(
        DS::Manifest::Entry.new manifest_row
      ).to be_a DS::Manifest::Entry
    end
  end

  context 'attributes' do

    it 'has a holding_institution_ds_qid' do
      expect(entry.institution_ds_qid).to eq 'Q49117'
    end
    it 'has a filename' do
      expect(entry.filename).to eq '9951865503503681_marc.xml'
    end
    it 'has a institution_wikidata_label' do
      expect(entry.institution_wikidata_label).to eq 'University of Pennsylvania'
    end
    it 'has a source_type' do
      expect(entry.source_type).to eq DS::Manifest::Entry::MARC_XML
    end
    it 'has a ds_id' do
      expect(entry.ds_id).to eq 'DS10000'
    end
    it 'has a institutional_id' do
      expect(entry.institutional_id).to eq '9951865503503681'
    end
    it 'has a record_lookup_value' do
      expect(entry.record_lookup_value).to eq '9951865503503681'
    end
    it 'has a lookup_value_location_in_source' do
      expect(entry.lookup_value_location_in_source).to eq "controlfield[@tag='001']/text()"
    end
    it 'has a record_last_updated' do
      expect(entry.record_last_updated).to eq '20220803105830'
    end
    it 'has a call_number' do
      expect(entry.call_number).to eq 'LJS 101'
    end
    it 'has a title' do
      expect(entry.title).to eq 'Periermenias Aristotelis ... [etc.]'
    end
    it 'has a iiif_manifest_url' do
      expect(entry.iiif_manifest_url).to eq 'https://example.com'
    end
    it 'has a link_to_institutional_record' do
      expect(entry.link_to_institutional_record).to eq 'https://example-2.com'
    end
    it 'has a manifest_generated_at' do
      expect(entry.manifest_generated_at).to eq '2023-07-25T09:52:02-0400'
    end
    it 'has a dated' do
      expect(entry.dated.to_s.downcase).to eq 'true'
    end
  end

  context '#iiif_manifest_url' do
    let(:row) {
      { DS::Manifest::Entry::IIIF_MANIFEST_URL => 'https://example.com | https://example-2.com ; https://example-3.com https://example-4.com' }
    }
    let(:entry) { DS::Manifest::Entry.new row }

    it 'splits and joins the urls' do
      expect(entry.iiif_manifest_url).to eq 'https://example.com|https://example-2.com|https://example-3.com|https://example-4.com'
    end
  end

  context '[]' do
    it 'returns the correct value' do
      expect(entry[DS::Manifest::Entry::CALL_NUMBER]).to eq 'LJS 101'
    end
  end
end
