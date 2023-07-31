# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::Entry' do

  let(:manifest_row) { parse_csv(<<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,9951865503503681_marc.xml,University of Pennsylvania,MARC XML,DS10000,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
  EOF
  ).first
  }

  let(:entry) { DS::Manifest::Entry.new manifest_row }

  context 'initialize' do
    it 'creates a new DS::Manifest::Entry' do
      expect(
        DS::Manifest::Entry.new manifest_row
      ).to be_a DS::Manifest::Entry
    end
  end

  context 'attributes' do

    it 'has a institution_wikidata_qid' do
      expect(entry.institution_wikidata_qid).to eq 'Q49117'
    end
    it 'has a filename' do
      expect(entry.filename).to eq '9951865503503681_marc.xml'
    end
    it 'has a institution_wikidata_label' do
      expect(entry.institution_wikidata_label).to eq 'University of Pennsylvania'
    end
    it 'has a source_type' do
      expect(entry.source_type).to eq 'MARC XML'
    end
    it 'has a ds_id' do
      expect(entry.ds_id).to eq 'DS10000'
    end
    it 'has a institutional_id' do
      expect(entry.institutional_id).to eq '9951865503503681'
    end
    it 'has a institutional_id_location_in_source' do
      expect(entry.institutional_id_location_in_source).to eq '//marc:controlfield[@tag="001"]'
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
  end

  context '[]' do
    it 'returns the correct value' do
      expect(entry[DS::Manifest::Entry::CALL_NUMBER]).to eq 'LJS 101'
    end
  end

  context 'to_h' do
    let(:hash) {
      {:institution_wikidata_qid=>"Q49117",
       :institution_wikidata_label=>"University of Pennsylvania",
       :ds_id=>"DS10000",
       :call_number=>"LJS 101",
       :institutional_id=>"9951865503503681",
       :title=>"Periermenias Aristotelis ... [etc.]",
       :link_to_institutional_record=>"https://example-2.com",
       :iiif_manifest_url=>"https://example.com",
       :record_last_updated=>"20220803105830",
       :source_type=>"MARC XML",
       :filename=>"9951865503503681_marc.xml",
       :manifest_generated_at=>"2023-07-25T09:52:02-0400"}
    }

    it 'returns the correct hash' do
      expect(entry.to_h).to eq hash
    end
  end
end