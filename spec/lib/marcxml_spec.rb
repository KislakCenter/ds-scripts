require 'spec_helper'
require 'nokogiri'

describe DS::MarcXML do

  NS = { 'marc' =>  'http://www.loc.gov/MARC21/slim' }
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

  # let(:duplicate_genre_marc_record) { duplicate_genre_marc.xpath('record')[0] }
  context 'extract_genre_as_recorded' do
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
    it 'extracts the 245$a and 245$b' do
      expect(
        DS::MarcXML.extract_title_as_recorded(title_record)
      ).to eq 'Subfield a; Subfield b.'
    end
  end
end