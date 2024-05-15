# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Mapper::MarcMapper do

  let(:manifest) {  }

  let(:manifest_csv) { parse_csv(<<~EOF
    holding_institution_wikidata_qid,filename,holding_institution_wikidata_label,source_data_type,ds_id,holding_institution_institutional_id,institutional_id_location_in_source,record_last_updated,call_number,title,iiif_manifest_url,link_to_institutional_record,manifest_generated_at
    Q49117,marc_xml_with_all_values.xml,University of Pennsylvania,MARC XML,DS10000,9951865503503681,"//controlfield[@tag=""001""]",20220803105830,LJS 101,Periermenias Aristotelis ... [etc.],https://example.com,https://example-2.com,2023-07-25T09:52:02-0400
    Q49117,9949533433503681_marc.xml,University of Pennsylvania,MARC XML,,9949533433503681,"controlfield[@tag='001']/text()",20220803105856,Oversize LJS 280,Decretales a[b]breviate,https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3wm13v03/manifest,https://franklin.library.upenn.edu/catalog/FRANKLIN_9949533433503681,2023-08-01T11:31:22-0400

  EOF
  )
  }
  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_path) { File.join marc_xml_dir, 'manifest.csv' }

  let(:manifest_row) { manifest_csv.first }

  let(:manifest) {
    DS::Manifest::Manifest.new manifest_path, marc_xml_dir
  }

  let(:entry) { DS::Manifest::Entry.new manifest_row, manifest }

  let(:xml_file) {
    File.join marc_xml_dir, '9951865503503681_marc.xml'
  }

  let(:timestamp) { Time.now }

  let(:mapper) {
    DS::Mapper::MarcMapper.new(
      source_dir: marc_xml_dir,
      timestamp: timestamp
    )
  }

  let(:extractor) { DS::Extractor::MarcXml }

  context 'mapper implementation' do
    except = %i[extract_acknowledgments]
    it_behaves_like 'an extractor mapper', except
  end

  context 'extract_record' do

    it 'returns an XML node' do
      expect(mapper.extract_record entry).to be_a Nokogiri::XML::Element
    end

    let(:institutional_id) { entry.institutional_id }
    let(:xpath) { entry.institutional_id_location_in_source }
    let(:record) { mapper.extract_record entry }

    it 'returns the expected record' do
      expect(record.at_xpath(xpath).text).to eq entry.institutional_id
    end
  end

  context 'initialize' do
    it 'creates a DS::Mapper::MarcMapper' do
      expect(
        DS::Mapper::MarcMapper.new(
          source_dir: marc_xml_dir,
          timestamp: timestamp
        )
      ).to be_a DS::Mapper::MarcMapper
    end
  end

  context '#map_record' do

    let(:expected_map) {
      {
        :ds_id                              => "DS10000",
        :date_added                         => "",
        :date_last_updated                  => "",
        :dated                              => "",
        :source_type                        => "marc-xml",
        :cataloging_convention              => "amremm",
        :holding_institution                => "Q49117",
        :holding_institution_as_recorded    => "University of Pennsylvania",
        :holding_institution_id_number      => "9951865503503681",
        :holding_institution_shelfmark      => "LJS 101",
        :link_to_holding_institution_record => "https://example-2.com",
        :iiif_manifest                      => "https://example.com",
        :production_date                    => "850",
        :century                            => "9",
        :century_aat                        => "http://vocab.getty.edu/aat/300404501",
        :production_place_as_recorded       => "France",
        :production_place                   => "http://vocab.getty.edu/tgn/1000070",
        :production_place_label             => "France",
        :production_date_as_recorded        => "850?",
        :uniform_title_as_recorded          => "",
        :uniform_title_agr                  => "",
        :title_as_recorded                  => "Periermenias Aristotelis ... [etc.",
        :title_as_recorded_agr              => "",
        :standard_title                     => "",
        :genre_as_recorded                  => "Manuscripts, Medieval|Manuscripts, Latin--11th century|Manuscripts, Latin--9th century|Codices|Commentaries|Illuminations (visual works)|Poems|Treatises|Criticism, interpretation, etc|Early works|Specimens|Translations (documents)|Diagrams",
        :genre                              => "|||||||||http://id.worldcat.org/fast/1411636|||",
        :genre_label                        => "|||||||||Early works|||",
        :subject_as_recorded                =>
          "Aristotle|Aristotle--Criticism and interpretation--Early works to 1800|Aristotle. De interpretatione|De interpretatione (Aristotle)|Early works to 1800|Illumination of books and manuscripts, Carolingian--Specimens|Logic|Logic--Early works to 1800|Illumination of books and manuscripts, Carolingian|Criticism and interpretation",
        :subject                            => "|http://id.worldcat.org/fast/29885;http://id.worldcat.org/fast/1198648;http://id.worldcat.org/fast/1411636||||||||",
        :subject_label                      => "|Aristotle;Criticism and interpretation;Early works||||||||",
        :author_as_recorded                 => "Boethius, -524",
        :author_as_recorded_agr             => "",
        :author_wikidata                    => "Q102851",
        :author                             => "",
        :author_instance_of                 => "human",
        :author_label                       => "Boethius",
        :artist_as_recorded                 => "An Artist 1919-2001",
        :artist_as_recorded_agr             => "",
        :artist_wikidata                    => "",
        :artist                             => "",
        :artist_instance_of                 => "",
        :artist_label                       => "",
        :scribe_as_recorded                 => "A Scribe",
        :scribe_as_recorded_agr             => "",
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
        :language_as_recorded               => "Latin",
        :language                           => "Q397",
        :language_label                     => "Latin",
        :former_owner_as_recorded           => "Phillipps, Thomas, Sir, 1792-1872|Beck, Helmut, 1919-2001|Saint-Benoît-sur-Loire (Abbey)",
        :former_owner_as_recorded_agr       => "||",
        :former_owner_wikidata              => "Q2147709|Q94821473|Q956741",
        :former_owner                       => "",
        :former_owner_instance_of           => "human|human|organization",
        :former_owner_label                 => "Thomas Phillipps|Helmut Beck|Fleury Abbey",
        :material_as_recorded               => "parchment",
        :material                           => "http://vocab.getty.edu/aat/300011851",
        :material_label                     => "parchment",
        :physical_description               => "Extent: 64 leaves : parchment ; 204-206 x 172-174 (136-148 x 100-128) mm bound to 219 x 190 mm",
        :note                               =>
          "Ms. codex.|Origin: Written in north central France, possibly at the abbey in Saint-Benoît-sur-Loire, also known as the Abbaye de Fleury.|Title for manuscript from caption title for predominant work (f. 1v).|Decoration: 5 9th-century diagrams, 3 in the ink of the text (f. 37v, 54v) and 2 with colored inks added in the 11th century (f. 36r, 36v); 11th-century full-page decorated initial with Celtic knotwork and lions' heads (f. 1v); 2 11th-century 3-line initials in red and blue (f. 2r, 60v); 11th-century red and blue ink added to 9th-century 3-line initial (f. 5r); 1- and 2-line initials, mostly in the ink of the text (but alternating with red, f. 30-34); 2 3-line and many 2-line 11th-century calligraphic initials in ink of the text with simple ornamentation (f. 44-64).|Script: Written in a 9th-century Caroline minuscule, with replacement leaves in 11th-century Caroline minuscule at beginning (f. 1-4) and end (f. 45-64), with headings in rustic Latin capitals.|Layout: Written in 20 (f. 5-36), 23 (f. 1-4, 45-64), and 27 (f. 37-44) long lines, with the first line above the top line; ruled in drypoint, with a narrow vertical column at each side of the text block into which initials extend in part or in whole; prickings visible on most leaves.|Collation: Parchment, i (19th-century paper) + i (19th-century parchment) + 64 + i (19th-century parchment) + i (19th-century paper); 14 24(+4) 3-88 94; 1-64, 19th-century foliation in ink, upper right recto.|Binding: 19th-century English diced russia leather (lower flyleaf has J. Whatman 1832 watermark), bound for Sir Thomas Phillips.|Gift of Barbara Brizdle Schoenberg in honor of Amy Gutmann, President, University of Pennsylvania, 2014.|Sold at auction at Sotheby's as part of the Beck Collection, 16 June 1997, lot 3, to Lawrence J. Schoenberg.|Formerly owned by Sir Thomas Phillipps, ms. 2179 (stamped crest inside upper cover; inscription with alternate number 717, f. 1r; label on spine).|Sold by H. P. Kraus to Helmut Beck (Stuttgart), ms. 3 (embossed label, inside upper cover).|Sold as part of the residue of the Phillips collection first to William H. Robinson Ltd., 1945, and again to H. P. Kraus, Mar. 1978.|Sold by bookseller James Taylor (London) to Sir Thomas Phillipps, ca. 1826.",
        :data_processed_at                  => be_some_kind_of_date_time.or(be_blank),
        :data_source_modified               => "20220803105830",
        :source_file                        => "marc_xml_with_all_values.xml",
        :acknowledgements                   => ""
      }
    }

    it 'maps a record' do
      expect(mapper.map_record entry).to match expected_map
    end
  end

end
