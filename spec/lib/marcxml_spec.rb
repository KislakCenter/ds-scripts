require 'spec_helper'
require 'nokogiri'

describe DS::MarcXML do

  context 'extract_genre_as_recorded' do
    let(:duplicate_genre_record) {
      marc_record %q{<?xml version="1.0" encoding="UTF-8"?>
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat d</marc:controlfield>
        <marc:datafield ind1=" " ind2="7" tag="655">
          <marc:subfield code="a">Sermons.</marc:subfield>
          <marc:subfield code="2">lcgft</marc:subfield>
          <marc:subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</marc:subfield>
        </marc:datafield>
        <marc:datafield ind1=" " ind2="7" tag="655">
          <marc:subfield code="a">Other value.</marc:subfield>
        </marc:datafield>
        <marc:datafield ind1=" " ind2="7" tag="655">
          <marc:subfield code="a">Sermons.</marc:subfield>
          <marc:subfield code="2">lcgft</marc:subfield>
          <marc:subfield code="0">http://id.loc.gov/authorities/genreForms/gf2015026051</marc:subfield>
        </marc:datafield>
      </marc:record>
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
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat d</marc:controlfield>
        <marc:datafield ind1="0" ind2="0" tag="245">
          <marc:subfield code="a">Subfield a; </marc:subfield>
          <marc:subfield code="b">Subfield b.</marc:subfield>
        </marc:datafield>
      </marc:record>
    })
    }
    it 'extracts the 245$a and 245$b' do
      expect(
        DS::MarcXML.extract_title_as_recorded(title_record)
      ).to eq 'Subfield a; Subfield b.'
    end
  end



  context 'extract_data_as_recorded' do

    let(:date_260c_marc) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
        <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
          <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
          <marc:controlfield tag="001">9948617063503681</marc:controlfield>
          <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
          <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
          <marc:datafield ind1=" " ind2=" " tag="260">
            <marc:subfield code="a">Vienna ;</marc:subfield>
            <marc:subfield code="c">1644 February 10</marc:subfield>
          </marc:datafield>
        </marc:record>
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
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
        <marc:datafield ind1=" " ind2=" " tag="260">
          <marc:subfield code="a">[Italy,</marc:subfield>
          <marc:subfield code="d">14th and 15th centuries]</marc:subfield>
        </marc:datafield>
      </marc:record>
    }
      )
    }
    it 'extracts 260$d' do
      expect(
        DS::MarcXML.extract_date_as_recorded(date_260d_marc)
      ).to eq '14th and 15th centuries]'
    end

    let(:date_264c_marc) {
      marc_record(
        %q{<?xml version="1.0" encoding="UTF-8"?>
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
        <marc:datafield tag="264" ind1=" " ind2="0">
          <marc:subfield code="a">Lahore,</marc:subfield>
          <marc:subfield code="c">1596.</marc:subfield>
        </marc:datafield>
      </marc:record>
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
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat d</marc:controlfield>
        <marc:datafield ind1="0" ind2="0" tag="245">
          <marc:subfield code="a">Shah-nameh,</marc:subfield>
          <marc:subfield code="f">1600s.</marc:subfield>
        </marc:datafield>
      </marc:record>
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
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat d</marc:controlfield>
      </marc:record>
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
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
        <marc:datafield ind1=" " ind2=" " tag="260">
          <marc:subfield code="a">[Italy,</marc:subfield>
          <marc:subfield code="d">14th and 15th centuries]</marc:subfield>
        </marc:datafield>
      </marc:record>
    }
    )
  }

  let(:place_264a_record) {
    marc_record(
      %q{<?xml version="1.0" encoding="UTF-8"?>
      <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
        <marc:controlfield tag="001">9948617063503681</marc:controlfield>
        <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
        <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
        <marc:datafield tag="264" ind1=" " ind2="0">
          <marc:subfield code="a">Lahore,</marc:subfield>
          <marc:subfield code="c">1596.</marc:subfield>
        </marc:datafield>
      </marc:record>
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
            <marc:record xmlns:marc="http://www.loc.gov/MARC21/slim"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
              <marc:leader>12792ctm a2201573Ia 4500</marc:leader>
              <marc:controlfield tag="001">9948617063503681</marc:controlfield>
              <marc:controlfield tag="005">20220803105853.0</marc:controlfield>
              <marc:controlfield tag="008">101130s1409    it a          000 0 lat</marc:controlfield>
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
            </marc:record>
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
end