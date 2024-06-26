# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::ReconBuilder do

  context 'TEI XML recon' do
    let(:files) { "#{fixture_path 'tei_xml'}/lewis_o_031_TEI.xml" }
    let(:source_type) { DS::Constants::TEI_XML }
    let(:out_dir) { File.join DS.root, 'tmp' }
    let(:recon_builder) {
      Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
    }
    let(:extractor) { DS::Extractor::TeiXml }

    skips = %i{ named-subjects }
    it_behaves_like 'a ReconBuilder', skips

  end

  context 'MARC XML recon' do
    let(:files) { "#{fixture_path 'marc_xml'}/9951865503503681_marc.xml" }
    let(:source_type) { DS::Constants::MARC_XML }
    let(:out_dir) { File.join DS.root, 'tmp' }
    let(:recon_builder) {
      Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
    }
    let(:extractor) { DS::Extractor::MarcXmlExtractor }

    it_behaves_like 'a ReconBuilder'

    context '#each_recon' do
      let(:recon_type) { :places }
      context ':places' do
        let(:recons) {
          [
            {
              :authorized_label => "France",
              :place_as_recorded => "France",
              :as_recorded => "France",
              :structured_value => "http://vocab.getty.edu/tgn/1000070",
              :ds_qid=>be_blank.or(match /^Q\d+/),
            }
          ]

        }

        it 'yields the auth values' do
          expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
        end
      end

      context ':names' do
        let(:recon_type) { :names }

        let(:recons) {
          [
           {:authorized_label=>"Boethius",
            :instance_of=>"human",
            :name_agr=>"",
            :name_as_recorded=>"Boethius, -524",
            :as_recorded=>"Boethius, -524",
            :role=>"author",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n79029805",
            :structured_value=>"Q102851",
            :ds_qid=>'QBOETHIUS'},
           {:authorized_label=>"Thomas Phillipps",
            :instance_of=>"human",
            :name_agr=>"",
            :name_as_recorded=>"Phillipps, Thomas, Sir, 1792-1872",
            :as_recorded=>"Phillipps, Thomas, Sir, 1792-1872",
            :role=>"former owner",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n50078542",
            :structured_value=>"Q2147709",
            :ds_qid=>'QPHILLIPPS'},
            {:authorized_label=>"Helmut Beck",
            :instance_of=>"human",
            :name_agr=>"",
            :name_as_recorded=>"Beck, Helmut, 1919-2001",
            :as_recorded=>"Beck, Helmut, 1919-2001",
            :role=>"former owner",
            :source_authority_uri=>be_blank,
            :structured_value=>"Q94821473",
            :ds_qid=>'QBECK'},
           {:authorized_label=>"Fleury Abbey",
            :instance_of=>"organization",
            :name_agr=>"",
            :name_as_recorded=>"Saint-Benoît-sur-Loire (Abbey)",
            :as_recorded=>"Saint-Benoît-sur-Loire (Abbey)",
            :role=>"former owner",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n83019607",
            :structured_value=>"Q956741",
            :ds_qid=>'QBENOIT'},
          ]

        }

        it 'yields the auth values' do
          expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
        end
      end
    end
  end

  context 'CSV recon' do
    let(:files) { File.join fixture_path('ds_csv'), 'ucriverside-dscsv.csv' }
    let(:source_type) { 'ds-csv' }
    let(:out_dir) { File.join DS.root, 'tmp' }
    let(:recon_builder) {
      Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
    }
    let(:extractor) { DS::Extractor::DsCsvExtractor }

    it_behaves_like 'a ReconBuilder'

    context ':places' do
      let(:recon_type) { :places }

      let(:recons) {
        [
         {:authorized_label=>"Paris",
          :place_as_recorded=>"Paris",
          :as_recorded=>"Paris",
          :structured_value=>"http://vocab.getty.edu/tgn/paris_id",
          :ds_qid=>'QPARIS'},
          {:authorized_label=>"France",
          :place_as_recorded=>"France",
          :as_recorded=>"France",
          :structured_value=>"http://vocab.getty.edu/tgn/1000070",
          :ds_qid=>be_blank.or(match /^Q\d+/)},
        ]
      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ':materials' do
      let(:recon_type) { :materials }

      let(:recons) {
        [{:authorized_label=>"parchment;paper",
          :material_as_recorded=>"materials description",
          :as_recorded=>"materials description",
          :structured_value=>
            "http://vocab.getty.edu/aat/300014109;http://vocab.getty.edu/aat/300011851",
          :ds_qid=>'QMATERIAL1;QMATERIAL2',
          }]
      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ':names' do
      let(:recon_type) { :names }
      let(:recons) {
        [
         {:authorized_label=>"Author auth name",
          :instance_of=>"human",
          :name_agr=>"An author in original script",
          :name_as_recorded=>"An author",
          :as_recorded=>"An author",
          :role=>"author",
          :source_authority_uri=>'http://example.com/author_uri',
          :structured_value=>"WDQIDAUTHOR",
          :ds_qid=>'QAUTHOR'},
         {:authorized_label=>'An Artist',
          :instance_of=>'human',
          :name_agr=>nil,
          :name_as_recorded=>"An artist",
          :as_recorded=>"An artist",
          :role=>"artist",
          :source_authority_uri=>'https://example.com/name/arstist1_uri',
          :structured_value=>'Qabcedfghi',
          :ds_qid=>'QARTIST1',
         },
         {:authorized_label=>"Artist auth name",
          :instance_of=>"human",
          :name_agr=>"Another artist original script",
          :name_as_recorded=>"Another artist",
          :as_recorded=>"Another artist",
          :role=>"artist",
          :source_authority_uri=>'http://example.com/artist_uri',
          :structured_value=>"WDQIDARTIST",
          :ds_qid=>'QARTIST'},
          {:authorized_label=>"Scribe auth name",
          :instance_of=>"human",
          :name_agr=>"A scribe in original script",
          :name_as_recorded=>"A scribe",
          :as_recorded=>"A scribe",
          :role=>"scribe",
          :source_authority_uri=>'http://example.com/scribe_uri',
          :structured_value=>"WDQIDSCRIBE",
          :ds_qid=>'QSCRIBE'
         },
         {:authorized_label=>"Former owner auth name",
          :instance_of=>"organization",
          :name_agr=>"Former owner in original script",
          :name_as_recorded=>"Former owner as recorded",
          :as_recorded=>"Former owner as recorded",
          :role=>"former_owner",
          :source_authority_uri=>'http://example.com/owner_uri',
          :structured_value=>"WDQIDOWNER",
          :ds_qid=>'QOWNER'},
        ]
      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ":genres" do
      let(:recon_type) { :genres }
      let(:recons) {
        [
          {:authorized_label=>"",
              :genre_as_recorded=>"prayer books",
              :as_recorded=>"prayer books",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"glossaries",
              :genre_as_recorded=>"Glossaries",
              :as_recorded=>"Glossaries",
              :source_authority_uri=>nil,
              :structured_value=>"http://vocab.getty.edu/aat/300026189",
              :vocab=>'ds-genre',
              :ds_qid=>'QGENRE',},
          {:authorized_label=>"",
              :genre_as_recorded=>"A third genre",
              :as_recorded=>"A third genre",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An AAT term",
              :as_recorded=>"An AAT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"A second AAT term",
              :as_recorded=>"A second AAT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An LCGFT term",
              :as_recorded=>"An LCGFT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"Another LCGFT term",
              :as_recorded=>"Another LCGFT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
            :genre_as_recorded=>"A FAST term",
            :as_recorded=>"A FAST term",
            :source_authority_uri=>nil,
            :structured_value=>"",
            :vocab=>'ds-genre',
            :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"A second FAST term",
              :as_recorded=>"A second FAST term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An RBMSVC term",
              :as_recorded=>"An RBMSVC term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An LoBT term",
              :as_recorded=>"An LoBT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"books of hours",
              :as_recorded=>"books of hours",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocab=>'ds-genre',
              :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]
      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end

    end

    context ":subjects" do
      let(:recon_type) { :subjects }
      let(:recons) {
        [
         {:authorized_label=>"Topical auth label",
          :source_authority_uri=>nil,
          :structured_value=>"http://id.worldcat.org/fast/topical_subject",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A topical subject",
          :as_recorded=>"A topical subject",
          :vocab=>'ds-subject',
          :ds_qid=>'QTOPICAL'},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A geographical subject",
          :as_recorded=>"A geographical subject",
          :vocab=>'ds-subject',
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A chronological subject",
          :as_recorded=>"A chronological subject",
          :vocab=>'ds-subject',
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]

      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ":named_subjects" do
      let(:recon_type) { :'named-subjects' }
      let(:recons) {
        [
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A personal named subject",
          :as_recorded=>"A personal named subject",
          :vocab=>'ds-subject',
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"Named subject auth label",
          :source_authority_uri=>nil,
          :structured_value=>"http://id.worldcat.org/fast/named_subject",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A corporate named subject",
          :as_recorded=>"A corporate named subject",
          :vocab=>'ds-subject',
          :ds_qid=>'QNAMEDSUBJECT'},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A named event",
          :as_recorded=>"A named event",
          :vocab=>'ds-subject',
          :ds_qid=>be_blank.or(match /^Q\d+/),},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A uniform title subject",
          :as_recorded=>"A uniform title subject",
          :vocab=>'ds-subject',
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]

      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ":titles" do
      let(:recon_type) { :titles }
      let(:recons) {
        [
          {:title_as_recorded=>"Title",
           :as_recorded=>"Title",
           :title_as_recorded_agr=>"Title in vernacular",
           :uniform_title_as_recorded=>"Uniform title",
           :uniform_title_as_recorded_agr=>"Uniform title in vernacular",
           :authorized_label=>"Standard title",
           :ds_qid=>"QTITLE"},
          {:title_as_recorded=>"Book of Hours",
           :as_recorded=>"Book of Hours",
           :title_as_recorded_agr=>nil,
           :uniform_title_as_recorded=>nil,
           :uniform_title_as_recorded_agr=>nil,
           :authorized_label=>"",
           :ds_qid=>""},
          {:title_as_recorded=>"Bible",
           :as_recorded=>"Bible",
           :title_as_recorded_agr=>nil,
           :uniform_title_as_recorded=>nil,
           :uniform_title_as_recorded_agr=>nil,
           :authorized_label=>"",
           :ds_qid=>""}
        ]

      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

    context ":languages" do
      let(:recon_type) { :languages }
      let(:recons) {
        [
          { :language_as_recorded => "Arabic", :as_recorded => "Arabic", :language_code => "", :authorized_label => "Arabic", :structured_value => "Q13955", ds_qid: 'QARABIC' },
          { :language_as_recorded => "Farsi", :as_recorded => "Farsi", :language_code => "", :authorized_label => "Persian", :structured_value => "Q9168", ds_qid: 'QFARSI' },
          { :language_as_recorded => "Latin", :as_recorded => "Latin", :language_code => "", :authorized_label => "Latin", :structured_value => "Q397", ds_qid: nil }
        ]
      }

      it 'yields the auth values' do
        expect { |b| recon_builder.each_recon(recon_type, &b) }.to yield_successive_args(*recons)
      end
    end

  end

  context 'DS METS XML' do
    let(:files) { File.join fixture_path('ds_mets_xml'), 'ds_mets-nelson-atkins-kg40.xml' }
    let(:source_type) { DS::Constants::DS_METS }
    let(:out_dir) { File.join DS.root, 'tmp' }
    let(:recon_builder) {
      Recon::ReconBuilder.new source_type: source_type, files: files, out_dir: out_dir
    }
    let(:extractor) { DS::Extractor::DsMetsXmlExtractor }

    skips = %i{ genres named-subjects }
    it_behaves_like 'a ReconBuilder', skips
  end

end
