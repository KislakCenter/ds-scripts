# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::OPennTEIMapper do

  let(:xml_dir) { fixture_path 'tei_xml' }
  let(:xml_file) { File.join xml_dir, 'lewis_o_031_TEI.xml' }
  let(:record) { xml = File.open(xml_file) { |f| Nokogiri::XML f } }
  let(:timestamp) { Time.now }

  let(:csv_string) { <<~EOF
        holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
        Q49117,9951865503503681_marc.xml,University of Pennsylvania,marc-xml,DS10000,9951865503503681,"//marc:controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
      EOF
  }
  let(:manifest_path) { temp_csv csv_string}
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, xml_dir }
  let(:entry) { DS::Manifest::Entry.new manifest.csv.first, manifest}

  let(:mapper) {
    DS::Mapper::OPennTEIMapper.new(
      manifest_entry: entry, record: record, timestamp: timestamp
    )
  }


  context 'initialize' do
    it 'creates a DS::Mapper::OPennTEIMapper' do
      expect(
        DS::Mapper::OPennTEIMapper.new(
          manifest_entry: entry, record:record, timestamp: timestamp
        )
      ).to be_a DS::Mapper::OPennTEIMapper
    end
  end

  context 'map_record' do
    let(:recons) {
      [
        Recon::AllSubjects, Recon::Genres, Recon::Languages,
        Recon::Materials, Recon::Names, Recon::Places,
        Recon::Titles,
      ]
    }
    let(:extractor_calls) {
      %i{
          extract_production_date
          extract_production_date
          extract_production_place
          extract_title_as_recorded
          extract_title_as_recorded_agr
          extract_genre_as_recorded
          extract_subject_as_recorded
          extract_authors_as_recorded
          extract_authors_agr
          extract_artists_as_recorded
          extract_artists_agr
          extract_scribes_as_recorded
          extract_scribes_agr
          extract_language_as_recorded
          extract_former_owners_as_recorded
          extract_former_owners_agr
          extract_material_as_recorded
          extract_acknowledgments
          extract_physical_description
          extract_note
      }
    }

    let (:entry_calls) {
      %i{
          ds_id
          institution_wikidata_qid
          institution_wikidata_label
          institutional_id
          call_number
          link_to_institutional_record
          iiif_manifest_url
      }
    }


    it 'returns a hash' do
      add_stubs recons, :lookup, []
      expect(mapper.map_record).to be_a Hash
    end

    it 'calls all expected openn_tei methods' do
      add_stubs recons, :lookup, []
      add_expects objects: DS::OPennTEI, methods: extractor_calls, return_val: []

      mapper.map_record
    end

    it 'calls all expected entry methods' do
      add_stubs recons, :lookup, []
      add_expects objects: entry, methods: entry_calls, return_val: []

      mapper.map_record
    end

    it 'returns a hash with all expected keys' do
      add_stubs recons, :lookup, []
      hash = mapper.map_record
      expect(DS::Constants::HEADINGS - hash.keys).to be_empty
    end
  end
end