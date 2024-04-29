# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::TeiXmlMapper do

  let(:xml_dir) { fixture_path 'tei_xml' }
  let(:xml_file) { File.join xml_dir, 'lewis_o_031_TEI.xml' }
  let(:record) { xml = File.open(xml_file) { |f| Nokogiri::XML f } }
  let(:timestamp) { Time.now }

  let(:csv_string) { <<~EOF
        holding_institution_wikidata_qid,holding_institution_wikidata_label,ds_id,source_data_type,filename,holding_institution_institutional_id,institutional_id_location_in_source,call_number,link_to_institutional_record,record_last_updated,title,iiif_manifest_url,manifest_generated_at
        Q3087288,Free Library of Philadelphia,,tei-xml,lewis_o_031_TEI.xml,Lewis O 31,/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno,Lewis O 31,https://openn.library.upenn.edu/Data/0023/html/lewis_o_031.html,2019-12-12,Qaṭr al-nadā wa-ball al-ṣadā.,,2023-11-18T17:13:02-0500
      EOF
  }
  let(:manifest_path) { temp_csv csv_string}
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, xml_dir }
  let(:entry) { DS::Manifest::Entry.new manifest.csv.first, manifest}

  let(:mapper) {
    DS::Mapper::TeiXmlMapper.new(
      source_dir: xml_dir, timestamp: timestamp
    )
  }

  let(:extractor_calls) {
    %i{
          extract_production_date_as_recorded
          extract_production_places_as_recorded
          extract_titles_as_recorded
          extract_titles_as_recorded_agr
          extract_genres_as_recorded
          extract_subjects_as_recorded
          extract_authors_as_recorded
          extract_authors_as_recorded_agr
          extract_artists_as_recorded
          extract_artists_as_recorded_agr
          extract_scribes_as_recorded
          extract_scribes_as_recorded_agr
          extract_languages_as_recorded
          extract_former_owners_as_recorded
          extract_former_owners_as_recorded_agr
          extract_material_as_recorded
          extract_acknowledgments
          extract_physical_description
          extract_notes
      }
  }

  context 'initialize' do
    it 'creates a DS::Mapper::TeiXmlMapper' do
      expect(
        DS::Mapper::TeiXmlMapper.new(
          source_dir: xml_dir, timestamp: timestamp
        )
      ).to be_a DS::Mapper::TeiXmlMapper
    end
  end

  context 'DS::Mapper::BaseMapper implementation' do
    it 'implements #extract_record(entry)' do
      expect { mapper.extract_record entry }.not_to raise_error
    end


    it 'implements #map_record' do
      # don't run the mapping
      add_stubs DS::TeiXml, extractor_calls, []
      expect { mapper.map_record entry }.not_to raise_error
    end

    it 'implements #open_source' do
      expect { mapper.open_source entry }.not_to raise_error
    end

    it 'is a kind of BaseMapper' do
      expect(mapper).to be_a_kind_of DS::Mapper::BaseMapper
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
      expect(mapper.map_record entry).to be_a Hash
    end

    it 'calls all expected openn_tei methods' do
      add_stubs recons, :lookup, []
      add_expects objects: DS::TeiXml, methods: extractor_calls, return_val: []

      mapper.map_record entry
    end

    it 'returns a hash with all expected keys' do
      add_stubs recons, :lookup, []
      hash = mapper.map_record entry
      expect(DS::Constants::HEADINGS - hash.keys).to be_empty
    end
  end
end
