# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Recon::ReconManager' do

  let(:files) { File.join fixture_path('ds_csv'), 'ucriverside-dscsv.csv' }
  let(:enumerator) { Recon::DsCsvEnumerator.new files }
  let(:recon_manager) {
    Recon::ReconManager.new enumerator: enumerator, extractor: DS::DsCsv
  }

  context 'csv recon' do
    context '#recon_places' do
      it 'returns an array' do
        expect(recon_manager.recon_places).to be_an Array
      end

      let(:recons) {
        [
          ["France", "", ""],
          ["Paris", "Paris", "http://vocab.getty.edu/tgn/paris_id"]
        ]
      }

      it 'returns the places auth values' do
        expect(recon_manager.recon_places).to match recons
      end
    end

    context '#recon_materials' do
      it 'returns an array' do
        expect(recon_manager.recon_materials).to be_an Array
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
        expect(recon_manager.recon_materials).to match recons
      end
    end

    context "#recon_names" do
      let(:method) { :recon_names }
      let(:recons) {
        [
          ["A scribe", "scribe", "A scribe in original script", nil, "human", "Scribe auth name", "WDQIDSCRIBE"],
          ["An artist", "artist", nil, nil, "", "", ""],
          ["An author", "author", "An author in original script", nil, "human", "Author auth name", "WDQIDAUTHOR"],
          ["Another artist", "artist", "Another artist original script", nil, "human", "Artist auth name", "WDQIDARTIST"],
          ["Former owner as recorded", "former_owner", "Former owner in original script", nil, "organization", "Former owner auth name", "WDQIDOWNER"]
        ]
      }
      it 'returns an array' do
        expect(recon_manager.send(method)).to be_an Array
      end

      it 'returns the auth values' do
        expect(recon_manager.send(method)).to match recons
      end
    end

    context "#recon_genres" do
      let(:method) { :recon_genres }
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

      it 'returns an array' do
        expect(recon_manager.send(method)).to be_an Array
      end

      it 'returns the auth values' do
        expect(recon_manager.send(method)).to match recons
      end

    end

    context "#recon_subjects" do
      let(:method) { :recon_subjects }
      let(:recons) {
        [
          ["A chronological subject", nil, nil, "", ""],
          ["A geographical subject", nil, nil, "", ""],
          ["A topical subject", nil, nil, "Topical auth label", "http://id.worldcat.org/fast/topical_subject"]
        ]
      }

      it 'returns an array' do
        expect(recon_manager.send(method)).to be_an Array
      end

      it 'returns the auth values' do
        expect(recon_manager.send(method)).to match recons
      end
    end

    context "#recon_titles" do
      let(:method) { :recon_titles }
      let(:recons) {
        [
          ["Book of Hours", nil, nil, nil, ""],
          ["Title", "Title in vernacular", nil, nil, "Standard title"]
        ]
      }

      it 'returns an array' do
        expect(recon_manager.send(method)).to be_an Array
      end

      it 'returns the auth values' do
        expect(recon_manager.send(method)).to match recons
      end
    end

    context "#recon_languages" do
      let(:method) { :recon_languages }
      let(:recons) {
        [
          ["Arabic", nil, "Arabic", "Q13955"],
          ["Farsi", nil, "Persian", "Q9168"],
          ["Latin", nil, "Latin", "Q397"]
        ]
      }

      it 'returns an array' do
        expect(recon_manager.send(method)).to be_an Array
      end

      it 'returns the auth values' do
        expect(recon_manager.send(method)).to match recons
      end
    end

  end
end
