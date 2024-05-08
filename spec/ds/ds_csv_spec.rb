require 'spec_helper'
require 'nokogiri'

describe DS::DsCsv do

  let(:csv_fixture) {
    File.join fixture_path('ds_csv'), 'ucriverside-dscsv.csv'
  }

  let(:contributor_csv) {
    CSV.parse File.open(csv_fixture, 'r').read, headers: true
  }

  let(:record) { contributor_csv.first }

  context "extractor interface" do
    skips = { skip_other_names: true }
    it_behaves_like "an extractor", skips
    it_behaves_like "a recon extractor", skips
  end

  # Date Updated by Contributor
  context "extract_dsid" do
    it 'returns the DS ID' do
      expect(
        DS::DsCsv.extract_dsid record
      ).to eq "DS1234"
    end
  end

  context "extract_holding_institution_as_recorded" do
    it 'returns the name of the holding institution' do
      expect(
          DS::DsCsv.extract_holding_institution_as_recorded record
      ).to eq "UC Riverside"
    end
  end

  context "extract_source_type" do
    it 'returns the source type' do
      expect(
        DS::DsCsv.extract_source_type record
      ).to eq "ds-csv"
    end
  end

  context "extract_cataloging_convention" do
    it 'returns the cataloging convention' do
      expect(
        DS::DsCsv.extract_cataloging_convention record
      ).to eq "amremm"
    end
  end

  context "extract_holding_institution_id_number" do
    it 'returns the institutional identifier' do
      expect(
        DS::DsCsv.extract_holding_institution_id_number record
      ).to eq "9912345"
    end
  end

  context "extract_holding_institution_shelfmark" do
    it 'returns the shelfmark' do
      expect(
        DS::DsCsv.extract_holding_institution_shelfmark record
      ).to eq "BP128.57 .A2 1700z"
    end
  end

  context "extract_fragment_num_disambiguator" do
    it 'returns the disambiguator' do
      expect(
        DS::DsCsv.extract_fragment_num_disambiguator record
      ).to eq "frag 1"
    end
  end

   context "extract_link_to_holding_institution_record" do
    it 'returns the institutional URL' do
      expect(
        DS::DsCsv.extract_link_to_holding_institution_record record
      ).to eq "https://calisphere.org/item/ark:/86086/n2t72jgg/"
    end
  end

   context "extract_link_to_iiif_manifest" do
    it 'returns the IIIF manfest URL' do
      expect(
        DS::DsCsv.extract_link_to_iiif_manifest record
      ).to eq "https://example.com/iiif"
    end
  end

  context "extract_production_places_as_recorded" do
    it 'returns the production place' do
      expect(DS::DsCsv.extract_production_places_as_recorded(
        record)
      ).to eq ["Paris"]
    end
  end

  context "extract_production_date_as_recorded" do
    it 'returns the date string in an array' do
      expect(
        DS::DsCsv.extract_production_date_as_recorded record
      ).to eq ["circa 18th-20th century"]
    end
  end

  context "extract_production_date_as_recorded" do
    it 'returns the date string in an array' do
      expect(
        DS::DsCsv.extract_production_date_as_recorded record
      ).to eq ["circa 18th-20th century"]
    end
  end

  context "extract_production_date_start" do
    it 'returns the production date start year' do
        expect(
          DS::DsCsv.extract_production_date_start record
        ).to eq "1700"
    end
  end

  context "extract_production_date_end" do
    it 'returns the production date end year' do
        expect(
          DS::DsCsv.extract_production_date_end record
        ).to eq "1999"
    end
  end

  context "extract_dated" do
    it 'returns the dated column value' do
        expect(
          DS::DsCsv.extract_dated record
        ).to be_falsey
    end
  end

  context "extract_uniform_titles_as_recorded" do
    it 'returns the uniform titles' do
      expect(
        DS::DsCsv.extract_uniform_titles_as_recorded record
      ).to eq ["Uniform title"]
    end
  end

  context "extract_uniform_titles_as_recorded_agr" do
    it 'returns the uniform titles in original script' do
      expect(
        DS::DsCsv.extract_uniform_titles_as_recorded_agr record
      ).to eq ["Uniform title in vernacular"]
    end
  end

  context "extract_titles_as_recorded" do
    it 'returns the title' do
      expect(DS::DsCsv.extract_titles_as_recorded(
        record)
      ).to eq ["Title"]
    end
  end

  context "extract_title_as_recorded_agr" do
    it 'returns the title in original script' do
      expect(DS::DsCsv.extract_titles_as_recorded_agr(
        record)
      ).to eq ["Title in vernacular"]
    end
  end

  context "extract_genre_as_recorded" do
    let(:genres) {
      [
        "prayer books",
        "Glossaries",
        "A third genre",
        "An AAT term",
        "A second AAT term",
        "An LCGFT term",
        "Another LCGFT term",
        "A FAST term",
        "A second FAST term",
        "An RBMSVC term",
        "An LoBT term"
      ]
    }

    it 'returns the genres' do
      expect(
        DS::DsCsv.extract_genres_as_recorded record
      ).to eq genres
    end
  end

  context "extract_all_subjects_as_recorded" do
    let(:subjects) {
      [
        "A topical subject",
        "A geographical subject",
        "A chronological subject",
        "A personal named subject",
        "A corporate named subject",
        "A named event",
        "A uniform title subject"
      ]
    }

    it 'returns the subjects' do
      expect(
        DS::DsCsv.extract_all_subjects_as_recorded record
      ).to match subjects
    end
  end

  context "extract_subjects_as_recorded" do
    let(:subjects) {
      ["A topical subject", "A geographical subject", "A chronological subject"]
    }

    it 'returns the subjects' do
      expect(
        DS::DsCsv.extract_subjects_as_recorded record
      ).to eq subjects
    end
  end

  context "extract_named_subjects_as_recorded" do
    let(:subjects) {
      [
        "A personal named subject",
        "A corporate named subject",
        "A named event",
        "A uniform title subject",
      ]
    }

    it 'returns the subjects' do
      expect(
        DS::DsCsv.extract_named_subjects_as_recorded record
      ).to eq subjects
    end
  end



  context "extract_author_as_recorded" do
    it 'returns the authors' do
      expect(
        DS::DsCsv.extract_authors_as_recorded record
      ).to eq ["An author"]
    end
  end

  context "extract_author_as_recorded_agr" do
    it 'returns the authors' do
      expect(
        DS::DsCsv.extract_authors_as_recorded_agr record
      ).to eq ["An author in original script"]
    end
  end

  context "extract_artist_as_recorded" do
    it 'returns the artists' do
      expect(
        DS::DsCsv.extract_artists_as_recorded record
      ).to eq ["An artist", "Another artist"]
    end
  end

  context "extract_artist_as_recorded_agr" do
    it 'returns the artist names in vernacular script' do
      expect(
        DS::DsCsv.extract_artists_as_recorded_agr record
      ).to eq [nil, "Another artist original script"]
    end
  end

  context "extract_scribe_as_recorded" do
    it 'returns the scribes' do
      expect(
        DS::DsCsv.extract_scribes_as_recorded record
      ).to eq ["A scribe"]
    end
  end

  context "extract_scribe_as_recorded_agr" do
    it 'returns the scribes' do
      expect(
        DS::DsCsv.extract_scribes_as_recorded_agr record
      ).to eq ["A scribe in original script"]
    end
  end

  context "extract_former_owner_as_recorded" do
    it 'returns the former owners' do
      expect(
        DS::DsCsv.extract_former_owners_as_recorded record
      ).to eq ["Former owner as recorded"]
    end
  end


  context "extract_languages_as_recorded" do
    it 'returns the languages' do
      expect(DS::DsCsv.extract_languages_as_recorded(
        record)
      ).to eq ["Arabic", "Farsi"]
    end
  end

  context "extract_material_as_recorded" do
    it 'returns the material string' do
      expect(
        DS::DsCsv.extract_material_as_recorded record
      ).to eq "materials description"
    end
  end

  context "extract_dimensions" do
    it "returns the formatted dimensions" do
      expect(
        DS::DsCsv.extract_dimensions record
      ).to eq ["310 x 190 mm bound to 320 x 200 mm"]
    end
  end

  context "extract_physical_description" do
    # Format for MARC extraction:
    #
    #   Extent: 18 leaves : paper ; 190 x 140 (170 x 112) mm bound to 197 x 150 mm.
    it "returns the extent" do
      expect(
        DS::DsCsv.extract_physical_description record
      ).to eq ["Extent: 1 folio; materials description; 310 x 190 mm bound to 320 x 200 mm"]
    end
  end

  context "extract_note" do
    let(:notes) {
      [
        "Layout: 1 column, 24 lines",
        "Script: Carolingian",
        "Decoration: Illuminated manuscript",
        "Binding: Bound in vellum",
        "Other miscellaneous physical description",
        "Provenance: Purchased from Phillip J. Pirages Fine Books and Manuscripts, McMinnville, Oregon, 2017",
        "The first note",
        "The second note",
      ]
    }

    it 'returns all the notes' do
      expect(
        DS::DsCsv.extract_notes record
      ).to eq notes
    end
  end

  context "extract_acknowledgments" do
    it "returns the acknowledgment" do
      expect(
        DS::DsCsv.extract_acknowledgments record
      ).to eq ["Imad Bayoun and Ahmad AlKurdy helped to identify and describe this manuscript"]
    end
  end

  context "extract_recon_places" do
    it "returns the recon place data" do
      expect(
        DS::DsCsv.extract_recon_places record
      ).to be_an Array
    end

    it 'returns an array that includes the place as recorded data' do
      expect(
        DS::DsCsv.extract_recon_places record
      ).to include ["Paris"]
    end
  end

  context "extract_recon_titles" do
    it "returns the recon title data" do
      expect(
        DS::DsCsv.extract_recon_titles record
      ).to be_an Array
    end

    it "returns an array that includes the title as recorded data" do
      expect(
        DS::DsCsv.extract_recon_titles record
      ).to include ["Title", "Title in vernacular", nil, nil]
    end
  end

  context "extract_recon_genres" do
    it "returns the recon genre data" do
      expect(DS::DsCsv.extract_recon_genres record).to be_an Array
    end

    it "returns an array that includes genre data" do
      expect(DS::DsCsv.extract_recon_genres record).to include ["prayer books", nil, nil  ]
      expect(DS::DsCsv.extract_recon_genres record).to include ["An LoBT term", nil, nil  ]
    end
  end

  context "extract_recon_subjects" do
    it "returns the recon subject data" do
      expect(DS::DsCsv.extract_recon_subjects record).to include ["A personal named subject", nil, nil, nil  ]
      expect(DS::DsCsv.extract_recon_subjects record).to include ["A chronological subject", nil, nil, nil  ]
    end
  end

  context "extract_recon_names" do
    it "returns the recon name data" do
      expect(DS::DsCsv.extract_recon_names record).to be_an Array
    end

    it "returns an array that includes the author data" do
      expect(
        DS::DsCsv.extract_recon_names record
      ).to include ['An author', 'author', 'An author in original script', nil]
    end

    it "returns an array that includes the artist data" do
      # An artist|Another artist;;Another artist original script
      expect(DS::DsCsv.extract_recon_names record).to include ['An artist', 'artist', nil, nil]
      expect(DS::DsCsv.extract_recon_names record).to include ['Another artist', 'artist', 'Another artist original script', nil]
    end

    it "returns an array that includes the scribe data" do
      expect(DS::DsCsv.extract_recon_names record).to include ["A scribe", "scribe", "A scribe in original script", nil]
    end

    it "returns an array that includes the former owner data" do
      expect(DS::DsCsv.extract_recon_names record).to include ["Former owner as recorded", "former owner", "Former owner in original script", nil]
    end
  end

end
