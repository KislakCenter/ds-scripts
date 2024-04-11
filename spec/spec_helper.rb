require_relative '../lib/ds'
require 'nokogiri'
require 'csv'

module Helpers

  def default_xml
<<~EOF
      <?xml version="1.0" encoding="UTF-8"?>
      <marc:records xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
        <marc:record>
          <marc:leader>08292ctm a2200985Ma 4500</marc:leader>
          <marc:controlfield tag="001">9951865503503681</marc:controlfield>
          <marc:controlfield tag="005">20220803105830.0</marc:controlfield>
          <marc:controlfield tag="008">111107s0850    fr ap         000 0 lat d</marc:controlfield>
          <marc:datafield ind1=" " ind2=" " tag="035">
        <marc:subfield code="a">(OCoLC)1041906445</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="035">
        <marc:subfield code="a">(OCoLC)on1041906445</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="035">
        <marc:subfield code="a">(PU)5186550-penndb-Voyager</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="040">
        <marc:subfield code="a">PAU</marc:subfield>
        <marc:subfield code="b">eng</marc:subfield>
        <marc:subfield code="e">amremm</marc:subfield>
        <marc:subfield code="c">PAU</marc:subfield>
        <marc:subfield code="d">OCLCF</marc:subfield>
        <marc:subfield code="d">OCLCO</marc:subfield>
        <marc:subfield code="d">PAU</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="041">
        <marc:subfield code="a">lat</marc:subfield>
        <marc:subfield code="h">grc</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="090">
        <marc:subfield code="a">LJS 101</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="100">
        <marc:subfield code="a">Boethius,</marc:subfield>
        <marc:subfield code="d">-524.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/n79029805</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2="0" tag="245">
        <marc:subfield code="a">Periermenias Aristotelis ... [etc.].</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="0" tag="264">
        <marc:subfield code="a">[France],</marc:subfield>
        <marc:subfield code="c">[850?]</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="300">
        <marc:subfield code="a">64 leaves :</marc:subfield>
        <marc:subfield code="b">parchment ;</marc:subfield>
        <marc:subfield code="c">204-206 x 172-174 (136-148 x 100-128) mm bound to 219 x 190 mm</marc:subfield>
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
        <marc:subfield code="a">Ms. codex.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Origin: Written in north central France, possibly at the abbey in Saint-Benoît-sur-Loire, also known as the Abbaye de Fleury.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Title for manuscript from caption title for predominant work (f. 1v).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Decoration: 5 9th-century diagrams, 3 in the ink of the text (f. 37v, 54v) and 2 with colored inks added in the 11th century (f. 36r, 36v); 11th-century full-page decorated initial with Celtic knotwork and lions' heads (f. 1v); 2 11th-century 3-line initials in red and blue (f. 2r, 60v); 11th-century red and blue ink added to 9th-century 3-line initial (f. 5r); 1- and 2-line initials, mostly in the ink of the text (but alternating with red, f. 30-34); 2 3-line and many 2-line 11th-century calligraphic initials in ink of the text with simple ornamentation (f. 44-64).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Script: Written in a 9th-century Caroline minuscule, with replacement leaves in 11th-century Caroline minuscule at beginning (f. 1-4) and end (f. 45-64), with headings in rustic Latin capitals.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Layout: Written in 20 (f. 5-36), 23 (f. 1-4, 45-64), and 27 (f. 37-44) long lines, with the first line above the top line; ruled in drypoint, with a narrow vertical column at each side of the text block into which initials extend in part or in whole; prickings visible on most leaves.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Collation: Parchment, i (19th-century paper) + i (19th-century parchment) + 64 + i (19th-century parchment) + i (19th-century paper); 1⁴ 2⁴(+4) 3-8⁸ 9⁴; 1-64, 19th-century foliation in ink, upper right recto.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="500">
        <marc:subfield code="a">Binding: 19th-century English diced russia leather (lower flyleaf has J. Whatman 1832 watermark), bound for Sir Thomas Phillips.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">6. f.63r-64r: [Miscellaenous verses, definitions, and biblical commentary].</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">4. f.60r: Versus de singulis mensibus / [Decimus Magnus Ausonius].</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">3. f.53v-59v: Periermeniae / Apulei.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">2. f.1v-53r, 61r-62v: Periermenias Aristotelis / a Boetio translatas.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">1. f.1r: [Conclusion of a grammatical work, 7-line verse by Eugene II of Toledo, Isidore's definition of rhetoric].</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="505">
        <marc:subfield code="a">5. f.60v, 63r: [Sample letter of monk to abbot].</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2=" " tag="510">
        <marc:subfield code="a">Listed in Aristotelis Latinus: codices: supplementa altera (Bruges: Desclée, De Brouwer, 1961) as Phillipps 2179 in the holdings of booksellers L.K. and P.R. Robinson,</marc:subfield>
        <marc:subfield code="c">p. 73-74 (Codex 266).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2=" " tag="510">
        <marc:subfield code="a">Described in Transformation of knowledge: early manuscripts from the collection of Lawrence J. Schoenberg (London: Paul Holberton, 2006),</marc:subfield>
        <marc:subfield code="c">p. 12-13 (LJS 101).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="520">
        <marc:subfield code="a">9th-century copy of Boethius's Latin translation of Aristotle's De interpretatione, referred to in the manuscript as Periermenias, with the shorter of two commentaries that Boethius wrote on that work. Replacement leaves added in the 11th century to the beginning (f. 1-4) and end (f. 45-64) of the manuscript, in addition to providing the beginning and end of the Boethius (which is probably lacking 2 gatherings between extant gatherings 6 and 7), include the Periermeniae attributed to Apuleius in the medieval period, a poem by Decimus Magnus Ausonius on the seven days of Creation, a sample letter of a monk to an abbot with interlinear and marginal glosses, and other miscellaneous verses, definitions, and excerpts. Dot Porter, University of Pennsylvania, has determined that two groups of leaves are misbound; leaves 5-12 (the original order appears to have been 5, 9, 10, 6, 7, 11, 12, 8) and leaves 53-64 (the original order of the leaves appears to have been 61, 62, 53-60, 63, 64).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="524">
        <marc:subfield code="a">UPenn LJS 101.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="546">
        <marc:subfield code="a">Latin.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Gift of Barbara Brizdle Schoenberg in honor of Amy Gutmann, President, University of Pennsylvania, 2014.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Sold at auction at Sotheby's as part of the Beck Collection, 16 June 1997, lot 3, to Lawrence J. Schoenberg.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Formerly owned by Sir Thomas Phillipps, ms. 2179 (stamped crest inside upper cover; inscription with alternate number 717, f. 1r; label on spine).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Sold by H. P. Kraus to Helmut Beck (Stuttgart), ms. 3 (embossed label, inside upper cover).</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Sold as part of the residue of the Phillips collection first to William H. Robinson Ltd., 1945, and again to H. P. Kraus, Mar. 1978.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="561">
        <marc:subfield code="a">Sold by bookseller James Taylor (London) to Sir Thomas Phillipps, ca. 1826.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="590">
        <marc:subfield code="a">Lawrence J. Schoenberg &amp; Barbara Brizdle Manuscript Initiative.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="7" tag="600">
        <marc:subfield code="a">Aristotle.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/29885</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="0" tag="600">
        <marc:subfield code="a">Aristotle</marc:subfield>
        <marc:subfield code="x">Criticism and interpretation</marc:subfield>
        <marc:subfield code="v">Early works to 1800.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="0" tag="600">
        <marc:subfield code="a">Aristotle.</marc:subfield>
        <marc:subfield code="t">De interpretatione.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/n82039372</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="7" tag="630">
        <marc:subfield code="a">De interpretatione (Aristotle)</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1359296</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="648">
        <marc:subfield code="a">Early works to 1800.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="0" tag="650">
        <marc:subfield code="a">Illumination of books and manuscripts, Carolingian</marc:subfield>
        <marc:subfield code="v">Specimens.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="650">
        <marc:subfield code="a">Logic.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1002014</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="0" tag="650">
        <marc:subfield code="a">Logic</marc:subfield>
        <marc:subfield code="v">Early works to 1800.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/subjects/sh2008107110</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="650">
        <marc:subfield code="a">Illumination of books and manuscripts, Carolingian.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/967267</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="650">
        <marc:subfield code="a">Criticism and interpretation.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1198648</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="0" tag="655">
        <marc:subfield code="a">Manuscripts, Medieval.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="4" tag="655">
        <marc:subfield code="a">Manuscripts, Latin</marc:subfield>
        <marc:subfield code="y">11th century.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="4" tag="655">
        <marc:subfield code="a">Manuscripts, Latin</marc:subfield>
        <marc:subfield code="y">9th century.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Codices.</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300224200</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Commentaries.</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300026098</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Illuminations (visual works)</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Poems.</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300026451</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Treatises.</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300026681</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Criticism, interpretation, etc.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1411635</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Early works.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1411636</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Specimens.</marc:subfield>
        <marc:subfield code="2">fast</marc:subfield>
        <marc:subfield code="0">http://id.worldcat.org/fast/1423861</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Translations (documents)</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300027389</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2="7" tag="655">
        <marc:subfield code="a">Diagrams.</marc:subfield>
        <marc:subfield code="2">aat</marc:subfield>
        <marc:subfield code="0">http://vocab.getty.edu/aat/300015387</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="2" tag="700">
        <marc:subfield code="a">Apuleius.</marc:subfield>
        <marc:subfield code="t">Peri hermēneias.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/no2012016838</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2="2" tag="700">
        <marc:subfield code="a">Ausonius, Decimus Magnus.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/n80128611</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="700">
        <marc:subfield code="a">Phillipps, Thomas,</marc:subfield>
        <marc:subfield code="c">Sir,</marc:subfield>
        <marc:subfield code="d">1792-1872,</marc:subfield>
        <marc:subfield code="e">former owner.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/n50078542</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="1" ind2=" " tag="700">
        <marc:subfield code="a">Beck, Helmut,</marc:subfield>
        <marc:subfield code="d">1919-2001,</marc:subfield>
        <marc:subfield code="e">former owner.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="2" ind2=" " tag="710">
        <marc:subfield code="a">Saint-Benoît-sur-Loire (Abbey),</marc:subfield>
        <marc:subfield code="e">former owner.</marc:subfield>
        <marc:subfield code="0">http://id.loc.gov/authorities/names/n83019607</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="2" ind2=" " tag="710">
        <marc:subfield code="a">Lawrence J. Schoenberg Collection (University of Pennsylvania)</marc:subfield>
        <marc:subfield code="5">PU</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2=" " tag="740">
        <marc:subfield code="a">De interpretatione.</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="0" ind2="0" tag="773">
        <marc:subfield code="t">Lawrence J. Schoenberg Collection (University of Pennsylvania)</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="852">
        <marc:subfield code="b">Kislak Center for Special Collections, Rare Books and Manuscripts</marc:subfield>
        <marc:subfield code="a">University of Pennsylvania</marc:subfield>
        <marc:subfield code="e">3420 Walnut Street, Philadelphia, Pennsylvania 19104-6206.</marc:subfield>
        <marc:subfield code="j">LJS 101</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2="1" tag="856">
        <marc:subfield code="z">Video orientation</marc:subfield>
        <marc:subfield code="u">http://hdl.library.upenn.edu/1017.12/1333431</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2="1" tag="856">
        <marc:subfield code="z">Digital facsimile for download (OPenn)</marc:subfield>
        <marc:subfield code="u">https://openn.library.upenn.edu/Data/0001/html/ljs101.html</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2="2" tag="856">
        <marc:subfield code="3">The Lawrence J. Schoenberg and Barbara Brizdle Manuscript Initiative Fund Home Page</marc:subfield>
        <marc:subfield code="u">http://hdl.library.upenn.edu/1017.12/366278</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1="4" ind2="1" tag="856">
        <marc:subfield code="z">Digital facsimile for browsing (Colenda)</marc:subfield>
        <marc:subfield code="u">https://colenda.library.upenn.edu/catalog/81431-p3rd1b</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="902">
        <marc:subfield code="a">MARCIVE 2022</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="994">
        <marc:subfield code="a">C0</marc:subfield>
        <marc:subfield code="b">PAULM</marc:subfield>
      </marc:datafield>
          <marc:datafield ind1=" " ind2=" " tag="999">
        <marc:subfield code="a">DLA</marc:subfield>
        <marc:subfield code="b">20111222</marc:subfield>
      </marc:datafield>
          <marc:holdings>
            <marc:holding>
              <marc:holding_id>22335156650003681</marc:holding_id>
              <marc:call_number>LJS 101</marc:call_number>
              <marc:library>KislakCntr</marc:library>
              <marc:location>scmss</marc:location>
            </marc:holding>
          </marc:holdings>
        </marc:record>
      </marc:records>

    EOF
  end
  def fixture_path relpath
    path = File.join __dir__, 'fixtures', relpath
    return path if File.exist? path

    raise "Unable to find fixture: #{relpath} in #{__dir__}"
  end

  def marc_record xml_string
    xml = Nokogiri::XML xml_string
    xml.remove_namespaces!
    xml.xpath('record')[0]
  end

  def openn_tei xml_string
    xml = Nokogiri::XML xml_string
    xml.remove_namespaces!
    xml
  end

  def parse_csv csv_string
    CSV.parse csv_string, headers: true
  end

  def temp_csv csv_string
    temp = Tempfile.new
    temp.puts csv_string
    temp.rewind
    temp.path
  end

  def add_stubs objects, methods, return_val
    objs = *objects
    syms = *methods
    objs.each do |obj|
      syms.each do |method|
        allow(obj).to receive(method).and_return return_val
      end
    end
  end

  def add_expects objects:, methods:, args: nil, return_val:
    objs = *objects
    syms = *methods
    with = args ? [args].flatten : nil
    objs.each do |obj|
      syms.each do |method|
        if with
          expect(obj).to receive(method).with(*with).at_least(:once) { return_val }
        else
          expect(obj).to receive(method).at_least(:once) { return_val }
        end
      end
    end
  end

end

RSpec.configure do |c|
  c.fail_if_no_examples = true
  DS.env = 'test'
  DS.configure!
  # Do not run ReconData.update! for tests; recon CSVs are fixtures
  # Recon::ReconData.update!
  c.include Helpers
end

require_relative './expections'
require_relative 'support/extractor_examples'
require_relative 'support/recon_extractor_examples'
