require 'spec_helper'
require 'nokogiri'

describe DS::Extractor::DsCsvExtractor do

  let(:csv_fixture) {
    File.join fixture_path('ds_csv'), 'ucriverside-dscsv.csv'
  }

  let(:contributor_csv) {
    CSV.parse File.open(csv_fixture, 'r').read, headers: true
  }

  let(:record) { contributor_csv.first }

  context "extractor interface" do
    skips = %i{ other_names }
    it_behaves_like "an extractor", skips
    it_behaves_like "a recon extractor", skips
  end

  # Date Updated by Contributor
  context "extract_dsid" do
    it 'returns the DS ID' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_dsid record
      ).to eq "DS1234"
    end
  end

  context "extract_holding_institution_as_recorded" do
    it 'returns the name of the holding institution' do
      expect(
          DS::Extractor::DsCsvExtractor.extract_holding_institution_as_recorded record
      ).to eq "UC Riverside"
    end
  end

  context "extract_source_type" do
    it 'returns the source type' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_source_type record
      ).to eq "ds-csv"
    end
  end

  context "extract_cataloging_convention" do
    it 'returns the cataloging convention' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_cataloging_convention record
      ).to eq "amremm"
    end
  end

  context "extract_holding_institution_id_number" do
    it 'returns the institutional identifier' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_holding_institution_id_number record
      ).to eq "9912345"
    end
  end

  context "extract_holding_institution_shelfmark" do
    it 'returns the shelfmark' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_holding_institution_shelfmark record
      ).to eq "BP128.57 .A2 1700z"
    end
  end

  context "extract_fragment_num_disambiguator" do
    it 'returns the disambiguator' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_fragment_num_disambiguator record
      ).to eq "frag 1"
    end
  end

   context "extract_link_to_holding_institution_record" do
    it 'returns the institutional URL' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_link_to_holding_institution_record record
      ).to eq "https://calisphere.org/item/ark:/86086/n2t72jgg/"
    end
  end

   context "extract_link_to_iiif_manifest" do
    it 'returns the IIIF manfest URL' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_link_to_iiif_manifest record
      ).to eq "https://example.com/iiif"
    end
  end

  context "extract_production_places_as_recorded" do
    it 'returns the production place' do
      expect(DS::Extractor::DsCsvExtractor.extract_production_places_as_recorded(
        record)
      ).to eq ["Paris"]
    end
  end

  context "extract_production_date_as_recorded" do
    it 'returns the date string in an array' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_production_date_as_recorded record
      ).to eq ["circa 18th-20th century"]
    end
  end

  context "extract_production_date_as_recorded" do
    it 'returns the date string in an array' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_production_date_as_recorded record
      ).to eq ["circa 18th-20th century"]
    end
  end

  context "extract_production_date_start" do
    it 'returns the production date start year' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_production_date_start record
        ).to eq "1700"
    end
  end

  context "extract_production_date_end" do
    it 'returns the production date end year' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_production_date_end record
        ).to eq "1999"
    end
  end

  context "extract_date_range" do
    it 'returns the date range' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_date_range record, range_sep: "^"
        ).to eq ["1700^1999"]
    end

    context 'no date range' do
      let(:record) {
        {
          'Production Date START' => nil,
          'Production Date END' => nil
        }
      }

      it "returns an empty array if the date range is not present" do
        expect(
          DS::Extractor::DsCsvExtractor.extract_date_range record, range_sep: "^"
        ).to eq []
      end
    end

    context 'start date only' do
      let(:record) {
        {
          'Production Date START' => "1700",
          'Production Date END' => nil
        }
      }

      it 'returns the start' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_date_range record, range_sep: "^"
        ).to eq ['1700']
      end
    end

    context 'end date only' do
      let(:record) {
        {
          'Production Date START' => nil,
          'Production Date END' => "1999"
        }
      }

      it 'returns the end' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_date_range record, range_sep: "^"
        ).to eq ['1999']
      end
    end
  end

  context "extract_dated" do
    it 'returns the dated column value' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_dated record
        ).to be_falsey
    end
  end

  context "extract_uniform_titles_as_recorded" do
    it 'returns the uniform titles' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_uniform_titles_as_recorded record
      ).to eq ["Uniform title"]
    end
  end

  context "extract_uniform_titles_as_recorded_agr" do
    it 'returns the uniform titles in original script' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_uniform_titles_as_recorded_agr record
      ).to eq ["Uniform title in vernacular"]
    end
  end

  context "extract_titles_as_recorded" do
    it 'returns the title' do
      expect(DS::Extractor::DsCsvExtractor.extract_titles_as_recorded(
        record)
      ).to eq ["Title"]
    end
  end

  context "extract_title_as_recorded_agr" do
    it 'returns the title in original script' do
      expect(DS::Extractor::DsCsvExtractor.extract_titles_as_recorded_agr(
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
        DS::Extractor::DsCsvExtractor.extract_genres_as_recorded record
      ).to eq genres
    end
  end

  context '#extract_genres' do
    it 'all genres vocabs are "ds-genre"' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_genres(record).map &:vocab
      ).to all eq 'ds-genre'
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
        DS::Extractor::DsCsvExtractor.extract_all_subjects_as_recorded record
      ).to match subjects
    end
  end

  context "extract_subjects_as_recorded" do
    let(:subjects) {
      ["A topical subject", "A geographical subject", "A chronological subject"]
    }

    it 'returns the subjects' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_subjects_as_recorded record
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
        DS::Extractor::DsCsvExtractor.extract_named_subjects_as_recorded record
      ).to eq subjects
    end
  end



  context "extract_author_as_recorded" do
    it 'returns the authors' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_authors_as_recorded record
      ).to eq ["An author"]
    end
  end

  context "extract_author_as_recorded_agr" do
    it 'returns the authors' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_authors_as_recorded_agr record
      ).to eq ["An author in original script"]
    end
  end

  context "extract_artist_as_recorded" do
    it 'returns the artists' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_artists_as_recorded record
      ).to eq ["An artist", "Another artist"]
    end
  end

  context "extract_artist_as_recorded_agr" do
    it 'returns the artist names in vernacular script' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_artists_as_recorded_agr record
      ).to eq [nil, "Another artist original script"]
    end
  end

  context "extract_scribe_as_recorded" do
    it 'returns the scribes' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_scribes_as_recorded record
      ).to eq ["A scribe"]
    end
  end

  context "extract_scribe_as_recorded_agr" do
    it 'returns the scribes' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_scribes_as_recorded_agr record
      ).to eq ["A scribe in original script"]
    end
  end

  context "extract_former_owner_as_recorded" do
    it 'returns the former owners' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_former_owners_as_recorded record
      ).to eq ["Former owner as recorded"]
    end
  end


  context "extract_languages_as_recorded" do
    it 'returns the languages' do
      expect(DS::Extractor::DsCsvExtractor.extract_languages_as_recorded(
        record)
      ).to eq ["Arabic", "Farsi"]
    end
  end

  context "extract_material_as_recorded" do
    it 'returns the material string' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_material_as_recorded record
      ).to eq "materials description"
    end
  end

  context "extract_dimensions" do
    it "returns the formatted dimensions" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_dimensions record
      ).to eq ["310 x 190 mm bound to 320 x 200 mm"]
    end
  end

  context "extract_physical_description" do
    # Format for MARC extraction:
    #
    #   Extent: 18 leaves : paper ; 190 x 140 (170 x 112) mm bound to 197 x 150 mm.
    it "returns the extent" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_physical_description record
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
        "Note followed by a space",
        "Final note 1",
        "The second note",
      ]
    }

    it 'returns all the notes' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_notes record
      ).to eq notes
    end

    it 'returns no notes ending with whitespace' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_notes record
      ).not_to include /\s+$/
    end
  end

  context "extract_acknowledgments" do
    it "returns the acknowledgment" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_acknowledgments record
      ).to eq ["Imad Bayoun and Ahmad AlKurdy helped to identify and describe this manuscript"]
    end
  end

  context "extract_recon_places" do
    it "returns the recon place data" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_recon_places record
      ).to be_an Array
    end

    it 'returns an array that includes the place as recorded data' do
      expect(
        DS::Extractor::DsCsvExtractor.extract_recon_places record
      ).to include ["Paris"]
    end
  end

  context "extract_recon_titles" do
    it "returns the recon title data" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_recon_titles record
      ).to be_an Array
    end

    it "returns an array that includes the title as recorded data" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_recon_titles record
      ).to include ["Title", "Title in vernacular", "Uniform title", "Uniform title in vernacular"]
    end
  end

  context "extract_recon_genres" do
    it "returns the recon genre data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_genres record).to be_an Array
    end

    it "returns an array that includes genre data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_genres record).to include ["prayer books", 'ds-genre', nil  ]
      expect(DS::Extractor::DsCsvExtractor.extract_recon_genres record).to include ["An LoBT term", 'ds-genre', nil  ]
    end
  end

  context "extract_recon_subjects" do
    it "returns the recon subject data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_subjects record).to include ["A personal named subject", nil, 'ds-subject', nil  ]
      expect(DS::Extractor::DsCsvExtractor.extract_recon_subjects record).to include ["A chronological subject", nil, 'ds-subject', nil  ]
    end
  end

  context "extract_recon_names" do
    it "returns the recon name data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_names record).to be_an Array
    end

    it "returns an array that includes the author data" do
      expect(
        DS::Extractor::DsCsvExtractor.extract_recon_names record
      ).to include ['An author', 'author', 'An author in original script', nil]
    end

    it "returns an array that includes the artist data" do
      # An artist|Another artist;;Another artist original script
      expect(DS::Extractor::DsCsvExtractor.extract_recon_names record).to include ['An artist', 'artist', nil, nil]
      expect(DS::Extractor::DsCsvExtractor.extract_recon_names record).to include ['Another artist', 'artist', 'Another artist original script', nil]
    end

    it "returns an array that includes the scribe data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_names record).to include ["A scribe", "scribe", "A scribe in original script", nil]
    end

    it "returns an array that includes the former owner data" do
      expect(DS::Extractor::DsCsvExtractor.extract_recon_names record).to include ["Former owner as recorded", "former owner", "Former owner in original script", nil]
    end
  end

  context 'extract_property_for_header' do
    context 'without trailing white space' do
      let(:header) { "Title(s)" }
      let(:expected) { ["Title;;Title in vernacular"] }
      it 'returns the property values for the header' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_values_for_header header: header, record: record
        ).to eq expected
      end
    end

    context 'with trailing white space' do
      let(:header) { "Note 1" }
      it 'strips leading and trailing spaces from the property values' do
        expect(
          DS::Extractor::DsCsvExtractor.extract_values_for_header header: header, record: record
        ).not_to include /\s+$/
      end
    end
  end

  context 'mark_long' do
    let(:long_string) {
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }

    it 'prepends the value with a warning' do
      expect(
        subject.mark_long long_string
      ).to start_with "TEXT_EXCEEDS_400_CHARACTERS"
    end

    it 'returns the value if it is less than 400 characters' do
      expect(
        subject.mark_long "Lorem ipsum dolor sit amet"
      ).to eq "Lorem ipsum dolor sit amet"
    end

    let(:string_of_400_characters) {
      "a".ljust(400, "a")
    }

    it 'returns the value if it is 400 characters' do
      expect(
        subject.mark_long string_of_400_characters
      ).to eq string_of_400_characters
    end

    it 'returns nil if the value is nil' do
      expect(subject.mark_long nil).to be_nil
    end

    it 'returns the empty string if the value is an empty string' do
      expect(subject.mark_long "").to eq ""
    end

    context 'is called by other methods' do
      let(:long_note) {
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      }
      let(:long_acknowledgement) {
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
      }

      let(:record) {
        csv = parse_csv <<~CSV
Note 1,Acknowledgements
"A note|#{long_note}|Another note","Thank you|#{long_acknowledgement}|No, thank you."
        CSV
        csv.first
      }

      it 'marks the long note' do
        expect(
          subject.extract_notes record
        ).to include /TEXT_EXCEEDS_400_CHARACTERS/
      end

      it 'marks the long acknowledgement' do
        expect(
          subject.extract_acknowledgments record
        ).to include /TEXT_EXCEEDS_400_CHARACTERS/
      end
    end
  end

end
