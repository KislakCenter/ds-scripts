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
      ).to eq '14th and 15th centuries]'
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

    it 'returns a 500$a shelfmark' do
      expect(
        DS::MarcXML.find_shelfmark shelfmark_in_500a_record
      ).to eq 'Eugene, OR, Special Collections and University Archives, University of Oregon, MS 041.'
    end


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

    it 'returns a 099$a shelfmark' do
      expect(
        DS::MarcXML.find_shelfmark shelfmark_in_099a_record
      ).to eq 'Ms. 65'
    end
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
end