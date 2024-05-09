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
            ["France", "France", "http://vocab.getty.edu/tgn/1000070"]
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
            ["Beck, Helmut, 1919-2001", "former owner", "", "", "human", "Helmut Beck", "Q94821473"],
            ["Boethius, -524", "author", "", "http://id.loc.gov/authorities/names/n79029805", "human", "Boethius", "Q102851"],
            ["Phillipps, Thomas, Sir, 1792-1872", "former owner", "", "http://id.loc.gov/authorities/names/n50078542", "human", "Thomas Phillipps", "Q2147709"],
            ["Saint-Benoît-sur-Loire (Abbey)", "former owner", "", "http://id.loc.gov/authorities/names/n83019607", "organization", "Fleury Abbey", "Q956741"]
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
          ["France", "France", "http://vocab.getty.edu/tgn/1000070"],
          ["Paris", "Paris", "http://vocab.getty.edu/tgn/paris_id"]
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
        [
          [
            "materials description",
            "parchment;paper",
            "http://vocab.getty.edu/aat/300014109;http://vocab.getty.edu/aat/300011851"
          ]
        ]
      }

      it 'returns the materials auth values' do
        expect(recon_builder.extract_recons :materials).to match recons
      end
    end

    context ':names' do
      let(:recons) {
        [
          ["A scribe", "scribe", "A scribe in original script", nil, "human", "Scribe auth name", "WDQIDSCRIBE"],
          ["An artist", "artist", nil, nil, "", "", ""],
          ["An author", "author", "An author in original script", nil, "human", "Author auth name", "WDQIDAUTHOR"],
          ["Another artist", "artist", "Another artist original script", nil, "human", "Artist auth name", "WDQIDARTIST"],
          ["Former owner as recorded", "former_owner", "Former owner in original script", nil, "organization", "Former owner auth name", "WDQIDOWNER"]
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :names).to match recons
      end
    end

    context ":genres" do
      let(:recons) {
        [
          ["A FAST term", nil, nil, "", ""],
          ["A second AAT term", nil, nil, "", ""],
          ["A second FAST term", nil, nil, "", ""],
          ["A third genre", nil, nil, "", ""],
          ["An AAT term", nil, nil, "", ""],
          ["An LCGFT term", nil, nil, "", ""],
          ["An LoBT term", nil, nil, "", ""],
          ["An RBMSVC term", nil, nil, "", ""],
          ["Another LCGFT term", nil, nil, "", ""],
          ["Glossaries", nil, nil, "glossaries", "http://vocab.getty.edu/aat/300026189"],
          ["books of hours", nil, nil, "", ""],
          ["prayer books", nil, nil, "", ""]
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :genres).to match recons
      end

    end

    context ":subjects" do
      let(:recons) {
        [
          ["A chronological subject", nil, nil, nil, "", ""],
          ["A geographical subject", nil, nil, nil, "", ""],
          ["A topical subject", nil, nil, nil, "Topical auth label", "http://id.worldcat.org/fast/topical_subject"]
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :subjects).to match recons
      end
    end

    context ":named_subjects" do
      let(:recons) {
        [
          ["A corporate named subject", nil, nil, nil, "Named subject auth label", "http://id.worldcat.org/fast/named_subject"],
          ["A named event", nil, nil, nil, "", ""],
          ["A personal named subject", nil, nil, nil, "", ""],
          ["A uniform title subject", nil, nil, nil, "", ""]
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :'named-subjects').to match recons
      end
    end

    context ":titles" do
      let(:recons) {
        [
          ["Book of Hours", nil, nil, nil, ""],
          ["Title", "Title in vernacular", nil, nil, "Standard title"]
        ]
      }

      it 'returns the auth values' do
        expect(recon_builder.extract_recons :titles).to match recons
      end
    end

    context ":languages" do
      let(:recons) {
        [
          ["Arabic", nil, "Arabic", "Q13955"],
          ["Farsi", nil, "Persian", "Q9168"],
          ["Latin", nil, "Latin", "Q397"]
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
