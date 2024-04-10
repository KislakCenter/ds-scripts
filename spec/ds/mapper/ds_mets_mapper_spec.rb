# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::DSMetsMapper' do

  let(:manifest_csv) { parse_csv <<~EOF
    holding_institution_wikidata_qid,holding_institution_wikidata_label,ds_id,source_data_type,filename,holding_institution_institutional_id,institutional_id_location_in_source,call_number,link_to_institutional_record,record_last_updated,title,iiif_manifest_url,manifest_generated_at
    Q49204,Smith College,,ds-mets,cubanc_50_48_00206114.xml,Ms. 263,"mods:mods/mods:identifier[@type=""local""]/text()",Ms. 263,https://archive.org/details/Ms.263_48,2016-09-07T03:12:58,[Missal].|Missal (Smith College Ms. 263),https://iiif.archivelab.org/iiif/images_Ms.263_48/manifest.json,2023-12-16T12:51:52-0500
    EOF
  }
  let(:xml_dir) { fixture_path 'ds_mets_xml' }
  let(:manifest_path) { File.join xml_dir, 'manifest.csv' }
  let(:manifest_row) { manifest_csv.first }
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, xml_dir }
  let(:entry) { DS::Manifest::Entry.new manifest_row, manifest }
  let(:xml_file) {
    File.join xml_dir, 'cubanc_50_48_00206114.xml'
  }
  let(:timestamp) { Time.now }
  let(:mapper) {
    DS::Mapper::DSMetsMapper.new(
      source_dir: xml_dir,
      timestamp: timestamp
    )
  }

  let(:recon_classes) {
    [
      Recon::AllSubjects, Recon::Genres, Recon::Languages,
      Recon::Materials, Recon::Names, Recon::Places,
      Recon::Titles,
    ]
  }

  let(:ds10_methods) {
    %i{
          extract_production_place
          extract_date_as_recorded
          transform_production_date
          dated_by_scribe?
          extract_title
          extract_subjects
          extract_author
          extract_artist
          extract_scribe
          extract_other_name
          extract_language
          extract_ownership
          extract_support
          extract_physical_description
          extract_note
          extract_acknowledgements
          source_modified
    }
  }

  context 'initialize' do
    it 'creates a mapper' do
      mapper = DS::Mapper::DSMetsMapper.new source_dir: xml_dir, timestamp: timestamp
      expect(mapper).to be_a DS::Mapper::DSMetsMapper
    end
  end

  context '#map_record' do
    let(:mapped_record) { mapper.map_record entry }
    it 'returns a hash' do
      add_stubs recon_classes, :lookup, []

      expect(mapped_record).to be_a Hash
    end

    it 'calls all the expected DS10 methods' do
      add_stubs recon_classes, :lookup, []
      add_expects objects: DS::DsMetsXml, methods: ds10_methods, return_val: []

      mapper.map_record entry
    end
  end
end
