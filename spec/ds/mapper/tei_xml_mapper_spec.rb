# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::TeiXmlMapper do

  let(:xml_dir) { fixture_path 'tei_xml' }
  let(:xml_file) { File.join xml_dir, 'lewis_o_031_TEI.xml' }
  let(:record) { xml = File.open(xml_file) { |f| Nokogiri::XML f } }
  let(:timestamp) { Time.now }

  let(:csv_string) { <<~EOF
    holding_institution_wikidata_qid,holding_institution_wikidata_label,ds_id,source_data_type,filename,holding_institution_institutional_id,institutional_id_location_in_source,call_number,link_to_institutional_record,record_last_updated,title,iiif_manifest_url,manifest_generated_at
    Q3087288,Free Library of Philadelphia,,tei-xml,lewis_o_031_TEI.xml,Lewis O 31,/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno,Lewis O 31,https://openn.library.upenn.edu/Data/0023/html/lewis_o_031.html,2019-12-12,Qaṭr al-nadā wa-ball al-ṣadā.,https://some.iiif.manifest/,2023-11-18T17:13:02-0500
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

  let(:extractor) { DS::Extractor::TeiXml }

  context 'mapper implementation' do
    except = %i[
      extract_cataloging_convention
      extract_date_range
      extract_uniform_titles_as_recorded
      extract_uniform_titles_as_recorded_agr
      extract_titles_as_recorded_agr
      extract_authors_as_recorded_agr
      extract_scribes_as_recorded_agr
      extract_former_owners_as_recorded_agr
      extract_genre_vocabulary
    ]
    it_behaves_like 'an extractor mapper', except
  end

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

    it 'implements #open_source' do
      expect { mapper.open_source entry }.not_to raise_error
    end

    it 'is a kind of BaseMapper' do
      expect(mapper).to be_a_kind_of DS::Mapper::BaseMapper
    end
  end

  context '#map_record' do
    let(:expected_map) {
      {
        :ds_id                              => nil,
        :date_added                         => "",
        :date_last_updated                  => "",
        :dated                              => "",
        :cataloging_convention              => "",
        :source_type                        => "tei-xml",
        :holding_institution                => "Q3087288",
        :holding_institution_as_recorded    => "Free Library of Philadelphia",
        :holding_institution_id_number      => "Lewis O 31",
        :holding_institution_shelfmark      => "Lewis O 31",
        :link_to_holding_institution_record => "https://openn.library.upenn.edu/Data/0023/html/lewis_o_031.html",
        :iiif_manifest                      => "https://some.iiif.manifest/",
        :production_place_as_recorded       => "Flanders",
        :production_place                   => "",
        :production_place_label             => "",
        :production_date_as_recorded        => "1600-1757",
        :production_date                    => "1600^1757",
        :century                            => "17;18",
        :century_aat                        => "http://vocab.getty.edu/aat/300404511;http://vocab.getty.edu/aat/300404512",
        :title_as_recorded                  => "Qaṭr al-nadā wa-ball al-ṣadā.",
        :title_as_recorded_agr              => "قطر الندا وبل الصدا",
        :uniform_title_as_recorded          => "",
        :uniform_title_agr                  => "",
        :standard_title                     => "",
        :genre_as_recorded                  => "Codices (bound manuscripts)|Manuscripts (documents)",
        :genre                              => "|",
        :genre_label                        => "|",
        :subject_as_recorded                => "Arabic language--Grammar--Early works to 1800|Arabic language--Syntax--Early works to 1800|Manuscripts, Arabic--17th century|Manuscripts, Arabic--18th century",
        :subject                            => "|||",
        :subject_label                      => "|||",
        :author_as_recorded                 => "Ibn Hishām, ʻAbd Allāh ibn Yūsuf, 1309-1360|Unwrapped name",
        :author_as_recorded_agr             => "ابن هشام، عبد الله بن يوسف،|",
        :author_wikidata                    => "|",
        :author                             => "",
        :author_instance_of                 => "|",
        :author_label                       => "|",
        :artist_as_recorded                 => "An artist",
        :artist_as_recorded_agr             => "An artist vernacular",
        :artist_wikidata                    => "",
        :artist                             => "",
        :artist_instance_of                 => "",
        :artist_label                       => "",
        :scribe_as_recorded                 => "A scribe",
        :scribe_as_recorded_agr             => "A scribe vernacular",
        :scribe_wikidata                    => "WDQIDSCRIBE",
        :scribe                             => "",
        :scribe_instance_of                 => "human",
        :scribe_label                       => "Scribe auth name",
        :associated_agent_as_recorded       => "",
        :associated_agent_as_recorded_agr   => "",
        :associated_agent                   => "",
        :associated_agent_label             => "",
        :associated_agent_wikidata          => "",
        :associated_agent_instance_of       => "",
        :language_as_recorded               => "Arabic",
        :language                           => "Q13955",
        :language_label                     => "Arabic",
        :former_owner_as_recorded           => "Jamālī, Yūsuf ibn Shaykh Muḥammad|Lewis, John Frederick, 1860-1932",
        :former_owner_as_recorded_agr       => "يوسف بن شيخ محمد الجمالي.|",
        :former_owner_wikidata              => "|",
        :former_owner                       => "",
        :former_owner_instance_of           => "|",
        :former_owner_label                 => "|",
        :material_as_recorded               => "paper",
        :material                           => "http://vocab.getty.edu/aat/300014109",
        :material_label                     => "paper",
        :physical_description               => "Extent: 50 leaves : 215 x 155 (155 x 90) mm bound to 217 x 162 mm; paper",
        :acknowledgements                   => "",
        :note                               =>
          "Ms. codex.|Title from introduction (f. 1v).|Kabīkaj invocation on f. 1r.|Catalog entry describing the manuscript pasted onto f. 1r.|Binding: Laid paper over pasteboard with flap (Type II) and leather spine back. No decorations. Textblock is detached from cover.|Layout: 25 long lines.|Script: Written in naskh in black and red; pointed.|Decoration: Rubrications in red.|Provenance: Gift of Anne Baker Lewis in 1933.|Provenance: Formerly owned by Yūsuf ibn Shaykh Muḥammad al-Jamālī (note dated 1170 AH [1757], f. 1r).|Provenance: Formerly owned by John Frederick Lewis.",
        :data_processed_at                  => be_a_date_time_string,
        :data_source_modified               => be_a_date_time_string,
        :source_file                        => "lewis_o_031_TEI.xml"
      }
    }

    it 'maps a record' do
      expect(mapper.map_record entry).to match expected_map
    end
  end
end
