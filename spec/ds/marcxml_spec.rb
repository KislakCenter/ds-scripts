require 'spec_helper'
require 'nokogiri'

describe DS::MarcXML do

  context 'extract_genre_as_recorded' do
    let(:duplicate_genre_record) {
      marc_record %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat d</controlfield>
        <datafield ind1=" " ind2="7" tag="655">
          <subfield code="a">Sermons.</subfield>
          <subfield code="2">lcgft</subfield>
          <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        </datafield>
        <datafield ind1=" " ind2="7" tag="655">
          <subfield code="a">Other value.</subfield>
        </datafield>
        <datafield ind1=" " ind2="7" tag="655">
          <subfield code="a">Sermons.</subfield>
          <subfield code="2">lcgft</subfield>
          <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        </datafield>
      </record>
    }
    }
    it 'returns a list of unique genre terms when :uniq is true' do
      # duplicate_genre_marc.remove_namespaces!
      expect(DS::MarcXML.extract_genre_as_recorded(
        duplicate_genre_record, sub2: :all, sub_sep: '--', uniq: true).size
      ).to eq 2
    end

    it 'returns a list with non-unique genre terms by default' do
      # duplicate_genre_marc.remove_namespaces!
      expect(DS::MarcXML.extract_genre_as_recorded(
        duplicate_genre_record, sub2: :all, sub_sep: '--').size
      ).to eq 3
    end
  end

  context 'extract_title_as_recorded' do
    let(:title_record) {
      marc_record(%q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat d</controlfield>
        <datafield ind1="0" ind2="0" tag="245">
          <subfield code="a">Subfield a; </subfield>
          <subfield code="b">Subfield b.</subfield>
        </datafield>
      </record>
    })
    }
    it 'extracts the 245$a and 245$b' do
      expect(
        DS::MarcXML.extract_title_as_recorded(title_record)
      ).to eq 'Subfield a; Subfield b.'
    end
  end

  context 'genre extraction' do

    let(:record) {
      marc_record %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat d</controlfield>
        <datafield tag="655" ind1=" " ind2="7">
            <subfield code="a">Booksellers' copies (Provenance)</subfield>
            <subfield code="2">rbprov.</subfield>
        </datafield>
        <datafield ind1=" " ind2="7" tag="655">
          <subfield code="a">Sermons.</subfield>
          <subfield code="2">lcgft</subfield>
          <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        </datafield>
        <datafield ind1=" " ind2="7" tag="655">
          <subfield code="a">Term without vocabulary.</subfield>
          <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        </datafield>
        <datafield ind1=" " ind2="0" tag="655">
          <subfield code="a">Term with 655$2 == 0</subfield>
          <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        </datafield>

      </record>
    }
    }

    context 'extract_genre_as_recorded' do
      let(:terms) {
        DS::MarcXML.extract_genre_as_recorded record, sub2: :all
      }

      it 'extracts a genre string' do
        expect(terms).to include "Booksellers' copies (Provenance)"
      end

      it 'extracts all the genres' do
        expect(terms.size).to eq 4
      end

      it 'extracts genres based on vocabulary' do
        terms = DS::MarcXML.extract_genre_as_recorded record, sub2: 'rbprov'
        expect(terms).to eq ["Booksellers' copies (Provenance)"]
      end
    end

    context "extract_genre_vocabulary" do
      let(:result) { DS::MarcXML.extract_genre_vocabulary record }
      it 'extracts the vocabulary' do
        expect(result).to include 'lcgft'
      end

      it 'removes trailing periods from vocabularies' do
        expect(result).to include 'rbprov'
      end

      it 'returns three values' do
        expect(result).to match_array ['rbprov', 'lcgft', nil, 'lcsh']
      end

      it 'returns lcsh when the @ind2 is 0 (zero)' do
        expect(result).to include 'lcsh'
      end
    end

    context "extract_recon_genres" do
      let(:result) { DS::MarcXML.extract_recon_genres record }

      it 'returns an array genre data' do
        # <datafield ind1=" " ind2="7" tag="655">
        # <subfield code="a">Sermons.</subfield>
        # <subfield code="2">lcgft</subfield>
        #   <subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</subfield>
        # </datafield>
        expect(result).to include %w{ Sermons lcgft http://id.loc.gov/authorities/genreForms/gf2015026051 }
      end

      it 'returns data for all the genre datafields' do
        expect(result.size).to eq 4
      end
    end
  end

  context 'extract_data_as_recorded' do

    let(:date_260c_marc) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
        <record xmlns="http://www.loc.gov/MARC21/slim"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
          <leader>12792ctm a2201573Ia 4500</leader>
          <controlfield tag="001">9948617063503681</controlfield>
          <controlfield tag="005">20220803105853.0</controlfield>
          <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
          <datafield ind1=" " ind2=" " tag="260">
            <subfield code="a">Vienna ;</subfield>
            <subfield code="c">1644 February 10</subfield>
          </datafield>
        </record>
      }
      )
    }

    it 'extracts 260$c' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_260c_marc)
      ).to eq '1644 February 10'
    end

    let(:date_260d_marc) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
        <datafield ind1=" " ind2=" " tag="260">
          <subfield code="a">[Italy,</subfield>
          <subfield code="d">14th and 15th centuries]</subfield>
        </datafield>
      </record>
    }
      )
    }
    it 'extracts 260$d' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_260d_marc)
      ).to eq '14th and 15th centuries'
    end

    let(:date_264c_marc) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">Lahore,</subfield>
          <subfield code="c">1596.</subfield>
        </datafield>
      </record>
    }
      )
    }

    it 'extracts 264$c' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_264c_marc)
      ).to eq '1596.'
    end


    let(:date_245f_record) {
      marc_record(%q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat d</controlfield>
        <datafield ind1="0" ind2="0" tag="245">
          <subfield code="a">Shah-nameh,</subfield>
          <subfield code="f">1600s.</subfield>
        </datafield>
      </record>
    }
      )
    }
    it 'extracts 245$f' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_245f_record)
      ).to eq '1600s.'
    end

    let(:date_008_record) {
      marc_record(%q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat d</controlfield>
      </record>
    })
    }
    it 'extracts 008[7,9]' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_008_record)
      ).to eq '1409'
    end
  end

  let(:place_260a_record) {
    marc_record(
      %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
        <datafield ind1=" " ind2=" " tag="260">
          <subfield code="a">[Italy,</subfield>
          <subfield code="d">14th and 15th centuries]</subfield>
        </datafield>
      </record>
    }
    )
  }

  let(:place_264a_record) {
    marc_record(
      %q{<?xml version="1.0" encoding="UTF-8"?>
      <record xmlns="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <leader>12792ctm a2201573Ia 4500</leader>
        <controlfield tag="001">9948617063503681</controlfield>
        <controlfield tag="005">20220803105853.0</controlfield>
        <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
        <datafield tag="264" ind1=" " ind2="0">
          <subfield code="a">Lahore,</subfield>
          <subfield code="c">1596.</subfield>
        </datafield>
      </record>
    }
    )
  }

  context 'extract_place_as_recorded' do

    it 'extracts 260$a' do
      expect(
        DS::MarcXML::extract_place_as_recorded place_260a_record
        ).to eq %w{ Italy }
    end

    it 'extracts 264$a' do
      expect(
        DS::MarcXML::extract_place_as_recorded place_264a_record
      ).to eq %w{ Lahore }
    end
  end

  context 'extract_recon_places' do
    it 'extracts 260$a' do
      expect(
        DS::MarcXML::extract_recon_places place_260a_record
      ).to eq [['Italy']]
    end

    it 'extracts 264$a' do
      expect(
        DS::MarcXML::extract_recon_places place_264a_record
      ).to eq [['Lahore']]
    end
  end

  context 'extract_authors_as_recorded' do
    let(:authors_record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1="1" ind2=" " tag="100">
                <subfield code="a">Cicero, Marcus Tullius,</subfield>
                <subfield code="e">author.</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="100">
                <subfield code="a">Halgren, John,</subfield>
                <subfield code="c">of Abbeville.</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="100">
                <subfield code="a">Gregory</subfield>
                <subfield code="b">I,</subfield>
                <subfield code="c">Pope,</subfield>
                <subfield code="d">approximately 540-604.</subfield>
              </datafield>
              <datafield ind1="2" ind2=" " tag="110">
                <subfield code="a">Catholic Church.</subfield>
              </datafield>
              <datafield ind1="2" ind2=" " tag="111">
                <subfield code="a">Council of Nicea.</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="700">
                <subfield code="a">Pseudo-Cicero,</subfield>
                <subfield code="e">author.</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="710">
                <subfield code="a">A bunch of monks,</subfield>
                <subfield code="e">author.</subfield>
              </datafield>
              <datafield ind1="0" ind2=" " tag="711">
                <subfield code="a">First Council of Nicea,</subfield>
                <subfield code="d">(325 :</subfield>
                <subfield code="c">Nicea)</subfield>
                <subfield code="e">author.</subfield>
              </datafield>
            </record>
        }
      )
    }

    it 'extracts 700$a' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Pseudo-Cicero'
    end

    it 'extracts 710$a' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'A bunch of monks'
    end

    it 'extracts 711$a$d$c' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'First Council of Nicea, (325 : Nicea)'
    end

    it 'extracts 100$a with an $e = author' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Cicero, Marcus Tullius'
    end

    it 'extracts 100$a without an $e' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Halgren, John, of Abbeville'
    end

    it 'extracts 100$a$b$c$d' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Gregory I, Pope, approximately 540-604'
    end

    it 'extracts 110$a' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Catholic Church'
    end

    it 'extracts 111$a' do
      expect(
        DS::MarcXML::extract_authors_as_recorded authors_record
      ).to include 'Council of Nicea'
    end
  end

  context 'extract note' do
    let(:record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Binding: Modern red morocco with marbled rose endpapers.</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Shelfmark: Eugene, OR, Special Collections and University Archives, University of Oregon, MS 041.</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Former shelfmark: Burgess Collection MS 19 (Bond &amp; Faye).</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">As referenced by Jim Marrow Report: "Book of Hours with an Office of the Dead of Autun Use."</subfield>
              </datafield>
              <datafield ind1="1" ind2=" " tag="561">
                <subfield code="a">Sold by Ronald Orlovsky (Ebay), 2017.</subfield>
              </datafield>
            </record>
        }
      )
    }
    let(:values) {
      DS::MarcXML.extract_note record
    }

    it 'extracts 561$a' do
      expect(values).to include 'Sold by Ronald Orlovsky (Ebay), 2017.'
    end

    it 'extracts 500$a' do
      expect(values).to include 'Binding: Modern red morocco with marbled rose endpapers.'
    end
  end

  context 'extract_named_500' do
    let(:note_500_record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Binding: Modern red morocco with marbled rose endpapers.</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Shelfmark: Eugene, OR, Special Collections and University Archives, University of Oregon, MS 041.</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Former shelfmark: Burgess Collection MS 19 (Bond &amp; Faye).</subfield>
              </datafield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">As referenced by Jim Marrow Report: "Book of Hours with an Office of the Dead of Autun Use."</subfield>
              </datafield>
              <datafield ind1="1" ind2=" " tag="561">
                <subfield code="a">Sold by Ronald Orlovsky (Ebay), 2017.</subfield>
              </datafield>
            </record>
        }
      )
    }
    it 'returns a named note with prefix' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'Binding'
      ).to include 'Binding: Modern red morocco with marbled rose endpapers.'
    end

    it 'returns 561$a' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'Binding'
      ).to include 'Binding: Modern red morocco with marbled rose endpapers.'
    end

    it 'returns a named note without a prefix' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'Binding', strip_name: true
      ).to include 'Modern red morocco with marbled rose endpapers.'
    end

    it 'handles a "name" parameter with a trailing ":"' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'Binding:'
      ).to include 'Binding: Modern red morocco with marbled rose endpapers.'
    end

    it 'has case-insensitive name matching' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'bInDiNg'
      ).to include 'Binding: Modern red morocco with marbled rose endpapers.'
    end

    it 'has case-insensitive name matching and stripping' do
      expect(
        DS::MarcXML.extract_named_500 note_500_record, name: 'bInDiNg', strip_name: true
      ).to include 'Modern red morocco with marbled rose endpapers.'
    end
  end

  context 'find_shelfmark' do
    let(:shelfmark_in_500a_record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1=" " ind2=" " tag="500">
                <subfield code="a">Shelfmark: Eugene, OR, Special Collections and University Archives, University of Oregon, MS 041.</subfield>
              </datafield>
            </record>
        }
      )
    }

    let(:shelfmark_in_099a_record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1=" " ind2=" " tag="099">
                <subfield code="a">Ms.</subfield>
                <subfield code="a">65</subfield>
                <subfield code="9">local</subfield>
              </datafield>
            </record>
        }
      )
    }
  end

  context 'extract_subject_as_recorded' do
    let(:subjects_marc_record) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>12792ctm a2201573Ia 4500</leader>
              <controlfield tag="001">9948617063503681</controlfield>
              <controlfield tag="005">20220803105853.0</controlfield>
              <controlfield tag="008">101130s1409    it a          000 0 lat</controlfield>
              <datafield ind1="1" ind2="0" tag="600">
                <subfield code="a">Cicero, Marcus Tullius</subfield>
                <subfield code="x">Spurious and doubtful works.</subfield>
              </datafield>
              <datafield ind1="2" ind2="7" tag="610">
                <subfield code="a">Catholic Church</subfield>
                <subfield code="2">fast</subfield>
                <subfield code="0">(OCoLC)fst00531720</subfield>
              </datafield>
              <datafield ind1="2" ind2="7" tag="611">
                <subfield code="a">First Council of Nicea</subfield>
                <subfield code="2">fast</subfield>
                <subfield code="0">(OCoLC)fst00531720</subfield>
              </datafield>
              <datafield ind1="0" ind2="0" tag="630">
                <subfield code="a">Bible.</subfield>
                <subfield code="p">Epistles of Paul</subfield>
                <subfield code="v">Commentaries.</subfield>
              </datafield>
              <datafield ind1=" " ind2="7" tag="647">
                <subfield code="a">Conspiracy of Catiline</subfield>
                <subfield code="c">(Rome :</subfield>
                <subfield code="d">65-62 B.C.)</subfield>
                <subfield code="2">fast</subfield>
                <subfield code="0">(OCoLC)fst01352536</subfield>
              </datafield>
              <datafield ind1=" " ind2="7" tag="648">
                <subfield code="a">600-1500</subfield>
                <subfield code="2">fast</subfield>
              </datafield>
              <datafield ind1=" " ind2="0" tag="650">
                <subfield code="a">Epic poetry, Persian.</subfield>
              </datafield>
              <datafield ind1=" " ind2="7" tag="651">
                <subfield code="a">Iran</subfield>
                <subfield code="2">fast</subfield>
                <subfield code="0">(OCoLC)fst01204889</subfield>
              </datafield>
            </record>
        }
      )
    }

    let(:subjects) { DS::MarcXML.extract_subject_as_recorded subjects_marc_record }

    it 'extracts 600' do
      expect(subjects).to include "Cicero, Marcus Tullius--Spurious and doubtful works"
    end

    it 'extracts 610' do
      expect(subjects).to include "Catholic Church"
    end

    it 'extracts 611' do
      expect(subjects).to include "First Council of Nicea"
    end

    it 'extracts 630' do
      expect(subjects).to include "Bible. Epistles of Paul--Commentaries"
    end

    it 'extracts 647'do
      expect(subjects).to include "Conspiracy of Catiline (Rome : 65-62 B.C.)"
    end

    it 'extracts 648' do
      expect(subjects).to include "600-1500"
    end

    it 'extracts 650' do
      expect(subjects).to include "Epic poetry, Persian"
    end

    it 'extracts 651' do
      expect(subjects).to include "Iran"
    end
  end

  context 'extract_cataloging_convention' do
    let(:record) {
      marc_record(%q{<?xml version="1.0" encoding="UTF-8"?>
            <record xmlns="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <leader>03556ctm a2200637Ia 4500</leader>
              <controlfield tag="001">9937281963503681</controlfield>
              <controlfield tag="005">20220803105900.0</controlfield>
              <controlfield tag="008">050322s1546    ne            000 0 dut d</controlfield>
              <datafield ind1=" " ind2=" " tag="035">
                <subfield code="a">(OCoLC)ocn155927441</subfield>
              </datafield>
                  <datafield ind1=" " ind2=" " tag="035">
                <subfield code="a">(OCoLC)155927441</subfield>
              </datafield>
                  <datafield ind1=" " ind2=" " tag="035">
                <subfield code="a">(PU)3728196-penndb-Voyager</subfield>
              </datafield>
                  <datafield ind1=" " ind2=" " tag="035">
                <subfield code="a">(CStRLIN)PAUR05-B10003</subfield>
              </datafield>
                  <datafield ind1=" " ind2=" " tag="040">
                <subfield code="a">PU</subfield>
                <subfield code="b">eng</subfield>
                <subfield code="e">amremm</subfield>
                <subfield code="c">PAULM</subfield>
                <subfield code="d">PAULM</subfield>
              </datafield>
            </record>
        }
      )
    }

    let(:extracted_values) { DS::MarcXML.extract_cataloging_convention record }

    it 'extracts 040$e' do
      expect(extracted_values).to eq 'amremm'
    end
  end

  context 'DS::Util.clean_string' do
    let(:record) {
      marc_record(%q{<?xml version="1.0" encoding="UTF-8"?>
  <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <marc:leader>04310ctm a2200613Ia 4500</marc:leader>
    <marc:controlfield tag="001">9968531423503681</marc:controlfield>
    <marc:controlfield tag="005">20220803105934.0</marc:controlfield>
    <marc:controlfield tag="008">160126q15001599xx            000 0 ara d</marc:controlfield>
    <marc:datafield ind1=" " ind2=" " tag="035">
  <marc:subfield code="a">(OCoLC)954274745</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="035">
  <marc:subfield code="a">(OCoLC)ocn954274745</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="035">
  <marc:subfield code="a">(PU)6853142-penndb-Voyager</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="040">
  <marc:subfield code="a">PAU</marc:subfield>
  <marc:subfield code="b">eng</marc:subfield>
  <marc:subfield code="e">amremm</marc:subfield>
  <marc:subfield code="c">PAU</marc:subfield>
  <marc:subfield code="d">OCLCO</marc:subfield>
  <marc:subfield code="d">PAU</marc:subfield>
  <marc:subfield code="d">STF</marc:subfield>
  <marc:subfield code="d">OCLCF</marc:subfield>
  <marc:subfield code="d">PAU</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2="9" tag="099">
  <marc:subfield code="a">CAJS Rar Ms 159</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2=" " tag="100">
  <marc:subfield code="6">880-01</marc:subfield>
  <marc:subfield code="a">Ibn Hishām, ʻAbd Allāh ibn Yūsuf,</marc:subfield>
  <marc:subfield code="d">1309-1360.</marc:subfield>
  <marc:subfield code="0">http://id.loc.gov/authorities/names/n82220489</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2="0" tag="240">
  <marc:subfield code="6">880-02</marc:subfield>
  <marc:subfield code="a">Mughnī al-labīb ʻan kutub al-aʻārīb</marc:subfield>
  <marc:subfield code="0">http://id.loc.gov/authorities/names/n85203377</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2="0" tag="245">
  <marc:subfield code="6">880-03</marc:subfield>
  <marc:subfield code="a">Mughnī al-labīb.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2="0" tag="264">
  <marc:subfield code="a">[Turkey?],</marc:subfield>
  <marc:subfield code="c">A.H. 889 (1484)</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="260">
  <marc:subfield code="c">[between 1500 and 1599?]</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="300">
  <marc:subfield code="a">175 leaves :</marc:subfield>
  <marc:subfield code="b">paper ;</marc:subfield>
  <marc:subfield code="c">245 x 170 (175 x 100) mm bound to 245 x 180 mm +</marc:subfield>
  <marc:subfield code="e">1 note</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="336">
  <marc:subfield code="a">text</marc:subfield>
  <marc:subfield code="b">txt</marc:subfield>
  <marc:subfield code="2">rdacontent</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="337">
  <marc:subfield code="a">unmediated</marc:subfield>
  <marc:subfield code="b">n</marc:subfield>
  <marc:subfield code="2">rdamedia</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="338">
  <marc:subfield code="a">volume</marc:subfield>
  <marc:subfield code="b">nc</marc:subfield>
  <marc:subfield code="2">rdacarrier</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="500">
  <marc:subfield code="a">A damaged leaf containing text and marginal notes from an unrelated manuscript is laid in.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="520">
  <marc:subfield code="a">Copy of a work on grammar; neatly written. A few pages at the beginning and end have had the edges restored, obscuring some text.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2=" " tag="541">
  <marc:subfield code="a">Gift of Mayer Sulzberger to the library of the Dropsie College for Hebrew and Cognate Learning (bookplate inside front cover), possibly in 1912 (pencil note, first flyleaf recto).</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="546">
  <marc:subfield code="a">Arabic.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2="0" tag="650">
  <marc:subfield code="a">Arabic language</marc:subfield>
  <marc:subfield code="0">http://id.loc.gov/authorities/subjects/sh2007101235</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2="7" tag="655">
  <marc:subfield code="a">Marginalia (annotations)</marc:subfield>
  <marc:subfield code="2">aat</marc:subfield>
  <marc:subfield code="0">http://vocab.getty.edu/aat/300026102</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="0" ind2=" " tag="700">
  <marc:subfield code="6">880-05</marc:subfield>
  <marc:subfield code="a">Ṣūlāqʹzādah, Muṣṭafá,</marc:subfield>
  <marc:subfield code="e">scribe.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="852">
  <marc:subfield code="b">Library at the Herbert D. Katz Center for Advanced Judaic Studies</marc:subfield>
  <marc:subfield code="a">University of Pennsylvania</marc:subfield>
  <marc:subfield code="e">420 Walnut Street, Philadelphia, Pennsylvania 19106-3703.</marc:subfield>
  <marc:subfield code="j">CAJS Rar Ms 159</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="4" ind2="1" tag="856">
  <marc:subfield code="z">Digital facsimile for browsing (Colenda)</marc:subfield>
  <marc:subfield code="u">https://colenda.library.upenn.edu/catalog/81431-p3br8mj3s</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="4" ind2="1" tag="856">
  <marc:subfield code="z">Digital facsimile for download (OPenn)</marc:subfield>
  <marc:subfield code="u">http://openn.library.upenn.edu/Data/0002/html/cajs_rarms159.html</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2=" " tag="880">
  <marc:subfield code="6">100-01//r</marc:subfield>
  <marc:subfield code="a">ابن هشام، عبد الله بن يوسف.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2="0" tag="880">
  <marc:subfield code="6">245-03//r</marc:subfield>
  <marc:subfield code="a">مغني اللبيب.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="1" ind2="0" tag="880">
  <marc:subfield code="6">240-02//r</marc:subfield>
  <marc:subfield code="a">مغني اللبيب عن كتب الاعاريب</marc:subfield>
  <marc:subfield code="0">http://id.loc.gov/authorities/names/n85203377</marc:subfield>
</marc:datafield>
    <marc:datafield ind1="0" ind2=" " tag="880">
  <marc:subfield code="6">700-05//r</marc:subfield>
  <marc:subfield code="a">صولاق‌زادة، مصطفى،</marc:subfield>
  <marc:subfield code="e">scribe.</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="902">
  <marc:subfield code="a">MARCIVE 2022</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="996">
  <marc:subfield code="a">hinge-right</marc:subfield>
</marc:datafield>
    <marc:datafield ind1=" " ind2=" " tag="999">
  <marc:subfield code="a">DLA</marc:subfield>
  <marc:subfield code="b">20160613</marc:subfield>
</marc:datafield>
    <marc:holdings>
      <marc:holding>
        <marc:holding_id>22253312400003681</marc:holding_id>
        <marc:call_number>CAJS Rar Ms 159</marc:call_number>
        <marc:library>KatzLib</marc:library>
        <marc:location>cjsrarms</marc:location>
      </marc:holding>
    </marc:holdings>
  </marc:record>

        }
      )
    }

    it 'is invoked by extract_place_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_place_as_recorded record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_date_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_date_as_recorded record
      expect(DS::Util).to have_received(:clean_string).at_least(:once)
    end

    it 'is invoked by extract_uniform_title_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_uniform_title_as_recorded record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_uniform_title_agr' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_uniform_title_agr record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_title_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_title_as_recorded record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_title_agr' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_title_agr record, 245
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_genre_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_genre_as_recorded(record, sub2: :all, sub_sep: '--', uniq: true).join('|')
      expect(DS::Util).to have_received(:clean_string).at_least(:once)
    end

    it 'is invoked by extract_subject_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_subject_as_recorded record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_language_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_language_as_recorded record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_names_as_recorded' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_names_as_recorded(record, tags: [700, 710, 711], relators: ['scribe']).join '|'
      expect(DS::Util).to have_received(:clean_string).at_most(10).times
    end

    it 'is invoked by extract_names_as_recorded_agr' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_names_as_recorded_agr(record, tags: [700, 710, 711], relators: ['scribe']).join '|'
      expect(DS::Util).to have_received(:clean_string).at_most(10).times
    end

    it 'is invoked by collect_datafields' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.collect_datafields(record, tags: 300, codes: 'b').join '|'
      expect(DS::Util).to have_received(:clean_string).at_most(10).times
    end

    it 'is invoked by extract_physical_description' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_physical_description record
      expect(DS::Util).to have_received :clean_string
    end

    it 'is invoked by extract_note' do
      allow(DS::Util).to receive(:clean_string).and_return ''
      DS::MarcXML.extract_note record
      expect(DS::Util).to have_received(:clean_string)
    end
  end
end