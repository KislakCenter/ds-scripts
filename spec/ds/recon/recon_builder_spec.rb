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

    it_behaves_like 'a ReconBuilder'

    context '#extract_recons' do
      context ':places' do
        let(:recons) {
          [
            {
              :authorized_label => "France",
              :place_as_recorded => "France",
              :structured_value => "http://vocab.getty.edu/tgn/1000070",
              :ds_qid=>be_blank.or(match /^Q\d+/),
            }
          ]

        }

        it 'returns the auth values' do
          expect(recon_builder.extract_recons :places).to match recons
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
            :role=>"author",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n79029805",
            :structured_value=>"Q102851",
            :ds_qid=>be_blank.or(match /^Q\d+/)},
           {:authorized_label=>"Thomas Phillipps",
            :instance_of=>"human",
            :name_agr=>"",
            :name_as_recorded=>"Phillipps, Thomas, Sir, 1792-1872",
            :role=>"former owner",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n50078542",
            :structured_value=>"Q2147709",
            :ds_qid=>be_blank.or(match /^Q\d+/)},
            {:authorized_label=>"Helmut Beck",
            :instance_of=>"human",
            :name_agr=>"",
            :name_as_recorded=>"Beck, Helmut, 1919-2001",
            :role=>"former owner",
            :source_authority_uri=>"",
            :structured_value=>"Q94821473",
            :ds_qid=>be_blank.or(match /^Q\d+/)},
           {:authorized_label=>"Fleury Abbey",
            :instance_of=>"organization",
            :name_agr=>"",
            :name_as_recorded=>"Saint-Benoît-sur-Loire (Abbey)",
            :role=>"former owner",
            :source_authority_uri=>"http://id.loc.gov/authorities/names/n83019607",
            :structured_value=>"Q956741",
            :ds_qid=>be_blank.or(match /^Q\d+/)},
          ]

        }

        it 'returns the auth values' do
          expect(recon_builder.extract_recons recon_type).to match recons
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

    it_behaves_like 'a ReconBuilder'

    context ':places' do
      it 'returns an array' do
        expect(recon_builder.extract_recons :places).to be_an Array
      end

      let(:recons) {
        [
         {:authorized_label=>"Paris",
          :place_as_recorded=>"Paris",
          :structured_value=>"http://vocab.getty.edu/tgn/paris_id",
          :ds_qid=>be_blank.or(match /^Q\d+/)},
          {:authorized_label=>"France",
          :place_as_recorded=>"France",
          :structured_value=>"http://vocab.getty.edu/tgn/1000070",
          :ds_qid=>be_blank.or(match /^Q\d+/)},
        ]
      }

      it 'returns the places auth values' do
        expect(recon_builder.extract_recons :places).to match recons
      end
    end

    context ':materials' do
      it 'returns an array' do
        expect(recon_builder.extract_recons :materials).to be_an Array
      end

      let(:recons) {
        [{:authorized_label=>"parchment;paper",
          :material_as_recorded=>"materials description",
          :structured_value=>
            "http://vocab.getty.edu/aat/300014109;http://vocab.getty.edu/aat/300011851",
          :ds_qid=>be_blank.or(match /^Q\d+/),
          }]
      }

      it 'returns the materials auth values' do
        expect(recon_builder.extract_recons :materials).to match recons
      end
    end

    context ':names' do
      let(:recons) {
        [
         {:authorized_label=>"Author auth name",
          :instance_of=>"human",
          :name_agr=>"An author in original script",
          :name_as_recorded=>"An author",
          :role=>"author",
          :source_authority_uri=>nil,
          :structured_value=>"WDQIDAUTHOR",
          :ds_qid=>be_blank.or(match /^Q\d+/),},
         {:authorized_label=>"",
          :instance_of=>"",
          :name_agr=>nil,
          :name_as_recorded=>"An artist",
          :role=>"artist",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :ds_qid=>be_blank.or(match /^Q\d+/),
         },
         {:authorized_label=>"Artist auth name",
          :instance_of=>"human",
          :name_agr=>"Another artist original script",
          :name_as_recorded=>"Another artist",
          :role=>"artist",
          :source_authority_uri=>nil,
          :structured_value=>"WDQIDARTIST",
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"Scribe auth name",
          :instance_of=>"human",
          :name_agr=>"A scribe in original script",
          :name_as_recorded=>"A scribe",
          :role=>"scribe",
          :source_authority_uri=>nil,
          :structured_value=>"WDQIDSCRIBE",
          :ds_qid=>be_blank.or(match /^Q\d+/),
         },
         {:authorized_label=>"Former owner auth name",
          :instance_of=>"organization",
          :name_agr=>"Former owner in original script",
          :name_as_recorded=>"Former owner as recorded",
          :role=>"former_owner",
          :source_authority_uri=>nil,
          :structured_value=>"WDQIDOWNER",
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :names).to match recons
      end
    end

    context ":genres" do
      let(:recons) {
        [
          {:authorized_label=>"",
              :genre_as_recorded=>"prayer books",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"glossaries",
              :genre_as_recorded=>"Glossaries",
              :source_authority_uri=>nil,
              :structured_value=>"http://vocab.getty.edu/aat/300026189",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"A third genre",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An AAT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"A second AAT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An LCGFT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"Another LCGFT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
            :genre_as_recorded=>"A FAST term",
            :source_authority_uri=>nil,
            :structured_value=>"",
            :vocabulary=>nil,
            :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"A second FAST term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An RBMSVC term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"An LoBT term",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
              :genre_as_recorded=>"books of hours",
              :source_authority_uri=>nil,
              :structured_value=>"",
              :vocabulary=>nil,
              :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :genres).to match recons
      end

    end

    context ":subjects" do
      let(:recons) {
        [
         {:authorized_label=>"Topical auth label",
          :source_authority_uri=>nil,
          :structured_value=>"http://id.worldcat.org/fast/topical_subject",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A topical subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A geographical subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A chronological subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]

      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :subjects).to match recons
      end
    end

    context ":named_subjects" do
      let(:recons) {
        [
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A personal named subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"Named subject auth label",
          :source_authority_uri=>nil,
          :structured_value=>"http://id.worldcat.org/fast/named_subject",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A corporate named subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A named event",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
         {:authorized_label=>"",
          :source_authority_uri=>nil,
          :structured_value=>"",
          :subfield_codes=>nil,
          :subject_as_recorded=>"A uniform title subject",
          :vocab=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]

      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :'named-subjects').to match recons
      end
    end

    context ":titles" do
      let(:recons) {
        [
         {:authorized_label=>"Standard title",
          :title_as_recorded=>"Title",
          :title_as_recorded_agr=>"Title in vernacular",
          :uniform_title_as_recorded=>nil,
          :uniform_title_as_recorded_agr=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
          {:authorized_label=>"",
          :title_as_recorded=>"Book of Hours",
          :title_as_recorded_agr=>nil,
          :uniform_title_as_recorded=>nil,
          :uniform_title_as_recorded_agr=>nil,
          :ds_qid=>be_blank.or(match /^Q\d+/),},
        ]

      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :titles).to match recons
      end
    end

    context ":languages" do
      let(:recons) {
        [
          { :language_as_recorded => "Arabic", :language_code => "", :authorized_label => "Arabic", :structured_value => "Q13955", ds_qid: nil },
          { :language_as_recorded => "Farsi", :language_code => "", :authorized_label => "Persian", :structured_value => "Q9168", ds_qid: nil },
          { :language_as_recorded => "Latin", :language_code => "", :authorized_label => "Latin", :structured_value => "Q397", ds_qid: nil }
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :languages).to match recons
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

    skips = %i{ genres named-subjects }
    it_behaves_like 'a ReconBuilder', skips
  end

end
