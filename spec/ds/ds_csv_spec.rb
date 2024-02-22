require 'spec_helper'
require 'nokogiri'

describe DS::DSCSV do

  let(:contributor_csv) {
    parse_csv <<~EOF
      row_index,Holding Institution,Source Type,Holding Institution Identifier,Shelfmark,Link to Institutional Record,IIIF Manifest,Production Place(s),Date Description,Production Date START,Production Date END,Dated,Uniform Title(s),Title(s),Genre 1,Genre 2,Genre 3,AAT Term(s),LCGFT Term(s),FAST Term(s),RBMSCV Term(s),LoBT Term(s),Named Subject(s): Personal,Named Subject(s): Corporate,Named Subject(s): Event,Named Subject(s): Uniform Title,Subject(s): Topical,Subject(s): Geographical,Subject(s): Chronological,Subject Vocabulary,Author Name(s),Artist Name(s),Scribe Name(s),Former Owner Name(s),Language(s),Materials Description,Material 1,Material 2,Material 3,Dimensions,Extent,Layout,Script,Decoration,Binding,Physical Description Miscellaneous,Provenance Notes,Note 1,Note 2,Acknowledgements
      1,UC Riverside,manual,,BP128.57 .A2 1700z,https://calisphere.org/item/ark:/86086/n2t72jgg/,https://example.com/iiif,Paris,circa 18th-20th century,1700,1999,FALSE,Al-Hajj,al-Ḥajj 1–15,prayer books [AAT 300026476],Qur'ans [AAT 300265128],A third genre,An AAT term|A second AAT term,An LCGFT term|Another LCGFT term,A FAST term|A second FAST term,An RBMSVC term,An LoBT term,A personal named subject,A corporate named subject,A named event,A uniform title subject,A topical subject,A geographical subject,A chronological subject,A subject vocabulary,An author,An artist,A scribe,Phillip J. Pirages Fine Books & Manuscripts,Arabic|Farsi,A materials description,paper [AAT 300014109],parchment [AAT 300011851],stone [AAT 1234567890],310 x 190 mm,1 folio,"1 column, 24 lines",Carolingian,Illuminated manuscript,Bound in vellum,Other miscellaneous physical description,"Purchased from Phillip J. Pirages Fine Books and Manuscripts, McMinnville, Oregon, 2017",The first note,The second note,Imad Bayoun and Ahmad AlKurdy helped to identify and describe this manuscript
    EOF
  }

  let(:dscsv_record) { contributor_csv.first }

  context "extract_production_date_as_recorded" do
    it 'returns the date string' do
      expect(
        DS::DSCSV.extract_production_date_as_recorded dscsv_record
      ).to eq ["circa 18th-20th century"]
    end
  end

  context "extract_production_place_as_recorded" do
    it 'returns the production place' do
      expect(DS::DSCSV.extract_production_place_as_recorded(
        dscsv_record)
      ).to eq ["Paris"]
    end
  end

  context "extract_uniform_title_as_recorded" do
    it 'returns the uniform title' do
      expect(
        DS::DSCSV.extract_uniform_title_as_recorded dscsv_record
      ).to eq ["Al-Hajj"]
    end
  end

  context "extract_title_as_recorded" do
    it 'returns the title' do
      expect(DS::DSCSV.extract_title_as_recorded(
        dscsv_record)
      ).to eq ["al-Ḥajj 1–15"]
    end
  end

  context "extract_material_as_recorded" do
    it 'returns the material string' do
      expect(
        DS::DSCSV.extract_material_as_recorded dscsv_record
      ).to eq ["A materials description"]
    end
  end

  context "extract_materials" do
    it 'returns the materials data' do

    end

  end

  context "extract_genre_as_recorded" do
    let(:genres) {
      [
        "prayer books [AAT 300026476]",
        "Qur'ans [AAT 300265128]",
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
        DS::DSCSV.extract_genre_as_recorded dscsv_record
      ).to eq genres
    end
  end

  context "extract_subject_as_recorded" do
    let(:subjects) {
      [
        "A personal named subject",
        "A named event",
        "A uniform title subject",
        "A corporate named subject",
        "A topical subject",
        "A geographical subject",
        "A chronological subject"
      ]
    }

    it 'returns the subjects' do
      expect(
        DS::DSCSV.extract_subject_as_recorded dscsv_record
      ).to eq subjects
    end
  end

  context "extract_author_as_recorded" do
    it 'returns the authors' do
      expect(
        DS::DSCSV.extract_author_as_recorded dscsv_record
      ).to eq ["An author"]
    end
  end

  context "extract_scribe_as_recorded" do
    it 'returns the scribes' do
      expect(
        DS::DSCSV.extract_scribe_as_recorded dscsv_record
      ).to eq ["A scribe"]
    end
  end

  context "extract_artist_as_recorded" do
    it 'returns the artists' do
      expect(
        DS::DSCSV.extract_artist_as_recorded dscsv_record
      ).to eq ["An artist"]
    end
  end

  context "extract_former_owner_as_recorded" do
    it 'returns the former owners' do
      expect(
        DS::DSCSV.extract_former_owner_as_recorded dscsv_record
      ).to eq ["Phillip J. Pirages Fine Books & Manuscripts"]
    end
  end

  context "extract_language_as_recorded" do
    it 'returns the languages' do
      expect(DS::DSCSV.extract_language_as_recorded(
        dscsv_record)
      ).to eq ["Arabic", "Farsi"]
    end
  end

  context "extract_physical_description" do
    # Format for MARC extraction:
    #
    #   Extent: 18 leaves : paper ; 190 x 140 (170 x 112) mm bound to 197 x 150 mm.
    it "returns the extent" do
      expect(
        DS::DSCSV.extract_physical_description dscsv_record
      ).to eq "Extent: 1 folio; 310 x 190 mm"
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
        DS::DSCSV.extract_note dscsv_record
      ).to eq notes
    end
  end

  context "source_modified" do

  end

end