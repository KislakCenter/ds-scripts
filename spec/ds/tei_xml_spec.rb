# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::TeiXml do

  let(:tei_file) {
    File.join fixture_path('tei_xml'), 'lewis_o_031_TEI.xml'
  }

  let(:record) {
    openn_tei open(tei_file, 'r').read
  }

  context "extractor interface" do
    skips = {
      skip_named_subjects: true,
      skip_cataloging_convention: true,
      skip_uniform_titles: true,
      skip_uniform_titles_agr: true,
      skip_other_names: true
    }

    it_behaves_like "a recon extractor", skips
    it_behaves_like "an extractor", skips
  end

  context 'extract_note' do
    let(:tei_xml) {
      openn_tei %q{<?xml version='1.0' encoding='UTF-8'?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <notesStmt>
                <note>Plain note.</note>
                <note type="relatedResource">Related resource note.</note>
              </notesStmt>
              <sourceDesc>
                <msDesc>
                  <physDesc>
                    <objectDesc>
                      <layoutDesc>
                        <layout>Layout note.</layout>
                      </layoutDesc>
                    </objectDesc>
                    <scriptDesc>
                      <scriptNote>Script note 1.</scriptNote>
                      <scriptNote>Script note 2.</scriptNote>
                    </scriptDesc>
                    <decoDesc>
                      <decoNote>Decoration note.</decoNote>
                    </decoDesc>
                    <bindingDesc>
                      <binding>
                        <p>Binding note.</p>
                      </binding>
                    </bindingDesc>
                  </physDesc>
                           <history>
                    <origin>
                      <origDate notBefore="1150" notAfter="1199"/>
                      <p>Second half of the 12th century</p>
                      <origPlace>Reims, France</origPlace>
                    </origin>
                    <provenance>Provenance note.</provenance>
                  </history>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>
      }
    }

    let(:notes) { DS::TeiXml.extract_notes tei_xml }

    it 'includes a note' do
      expect(notes).to include "Plain note."
    end

    it 'includes a binding note' do
      expect(notes).to include 'Binding: Binding note.'
    end

    it 'includes a layout note' do
      expect(notes).to include 'Layout: Layout note.'
    end

    it 'includes two script notes' do
      [
        'Script: Script note 1.',
        'Script: Script note 2.'
      ].each do |note|
        expect(notes).to include note
      end
    end

    it 'includes a decoration note' do
      expect(notes).to include 'Decoration: Decoration note.'
    end

    it 'includes a related resource note' do
      expect(notes).to include 'Related resource: Related resource note.'
    end

    it 'includes a provenance note' do
      expect(notes).to include 'Provenance: Provenance note.'
    end
  end

  context 'names' do
    let(:tei_xml) {
      openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <sourceDesc>
                <msDesc>
                  <msContents>
                    <summary>Clear copy of Ibn Hishām's grammar compendium. Two leaves have been sliced horizontally and are missing approximately the last 6 lines on each side (f. 11-12).</summary>
                    <textLang mainLang="ara">Arabic</textLang>
                    <msItem>
                      <title>Qaṭr al-nadā wa-ball al-ṣadā.</title>
                      <title type="vernacular">قطر الندا وبل الصدا</title>
                      <author>
                        <persName type="authority">Ibn Hishām, ʻAbd Allāh ibn Yūsuf, 1309-1360</persName>
                        <persName type="vernacular">ابن هشام، عبد الله بن يوسف،</persName>
                      </author>
                      <author>
                        <persName>persName Without Type</persName>
                      </author>
                      <author>
                        <name>name Without Type</name>
                      </author>
                      <author>
                        <name type="authority">Some Organization</name>
                      </author>
                      <author>
                        Unwrapped Name
                      </author>
                      <author>
                        <name type="authority">Free Library of Philadelphia. Rare Book Department. John Frederick Lewis collection of Oriental Manuscripts</name>
                      </author>
                      <respStmt>
                      <resp>former owner</resp>
                        <persName type="authority" ref="http://example.com">Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
                        <persName type="vernacular">يوسف بن شيخ محمد الجمالي.</persName>
                      </respStmt>
                      <respStmt>
                        <resp>former owner</resp>
                        <persName>Lewis, John Frederick, 1860-1932</persName>
                      </respStmt>
                      <respStmt>
                        <resp>former owner</resp>
                        <name>Name from name element</name>
                      </respStmt>
                      <respStmt>
                      <resp>donor</resp>
                        <persName type="authority">Lewis, Anne Baker, 1868-1937</persName>
                      </respStmt>
                      <respStmt>
                        <resp>artist</resp>
                        <persName type="authority">Artist One</persName>
                        <persName type="vernacular">Artist One Vernacular</persName>
                      </respStmt>
                        <respStmt>
                        <resp>artist</resp>
                        <persName type="authority">Artist Two</persName>
                      </respStmt>
                      <respStmt>
                        <resp>scribe</resp>
                        <persName type="authority">Scribe One</persName>
                        <persName type="vernacular">Scribe One Vernacular</persName>
                      </respStmt>
                        <respStmt>
                        <resp>scribe</resp>
                        <persName type="authority">Scribe Two</persName>
                      </respStmt>
                      </respStmt>
                      <respStmt>
                        <resp>some resp</resp>
                        <persName type="authority">Some Name</persName>
                      </respStmt>
                      <respStmt>
                        <resp>SOME resp</resp>
                        <persName type="authority">Some Other Name</persName>
                      </respStmt>
                    </msItem>
                  </msContents>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>}
    }

    context 'authors' do

      context 'extract_authors_as_recorded' do
        let(:authors) { DS::TeiXml.extract_authors_as_recorded tei_xml }
        it 'includes a persName[@type = "authority"]' do
          expect(authors).to include 'Ibn Hishām, ʻAbd Allāh ibn Yūsuf, 1309-1360'
        end

        it 'includes a name[@type = "authority"]' do
          expect(authors).to include 'Some Organization'
        end

        it 'includes an author without a <name> or <persName> element' do
          expect(authors).to include 'Unwrapped Name'
        end

        it 'includes an author with an untyped persName' do
          expect(authors).to include 'name Without Type'
        end

      end

      context 'extract_authors_agr_as_recorded' do
        let(:authors) { DS::TeiXml.extract_authors_as_recorded tei_xml }
        let(:authors_agr) { DS::TeiXml.extract_authors_as_recorded_agr tei_xml }
        it 'extracts an agr name' do
          expect(authors_agr).to include 'ابن هشام، عبد الله بن يوسف،'
        end

        it 'extracts nil when no vernacular name is present' do
          expect(authors_agr).to include nil
        end

        it 'extracts as many vernacular names/slots as names' do
          expect(authors_agr.size).to eq authors.size
        end
      end
    end

    context 'extract_resps' do
      let(:resps) { DS::TeiXml.extract_resps tei_xml, 'former owner' }
      it 'gets all the former owners' do
        expect(resps.size).to be > 0
      end

    end

    context 'former owners' do
      context 'extract_former_owners' do
        let(:former_owners) { DS::TeiXml.extract_former_owners_as_recorded tei_xml }
        it 'extracts a former owner' do
          expect(former_owners).to include 'Jamālī, Yūsuf ibn Shaykh Muḥammad'
        end

        it 'extracts all former owners' do
          expect(former_owners.size).to eq 3
        end
      end

      context 'extract_former_owners_agr' do
        let(:former_owners) { DS::TeiXml.extract_former_owners_as_recorded tei_xml }
        let(:former_owners_agr) { DS::TeiXml.extract_former_owners_as_recorded_agr tei_xml }

        it 'extracts a former owner vernacular name' do
          expect(former_owners_agr).to include 'يوسف بن شيخ محمد الجمالي.'
        end

        it 'extracts nil when no vernacular name is present' do
          expect(former_owners_agr).to include nil
        end

        it 'extracts as many vernacular names/slots as names' do
          expect(former_owners_agr.size).to eq former_owners.size
        end
      end
    end

    context 'artists' do
      context 'extract_artists' do
        let(:artists) { DS::TeiXml.extract_artists_as_recorded tei_xml }
        it 'extracts an artist' do
          expect(artists).to include 'Artist One'
        end

        it 'extracts all artists' do
          expect(artists.size).to eq 2
        end
      end

      context 'extract_artists_agr' do
        let(:artists) { DS::TeiXml.extract_artists_as_recorded tei_xml }
        let(:artists_agr) { DS::TeiXml.extract_artists_as_recorded_agr tei_xml }

        it 'extracts an artist vernacular name' do
          expect(artists_agr).to include 'Artist One Vernacular'
        end

        it 'extracts nil when no vernacular name is present' do
          expect(artists_agr).to include nil
        end

        it 'extracts as many vernacular names/slots as names' do
          expect(artists_agr.size).to eq artists.size
        end
      end
    end

    context 'scribes' do
      context 'extract_scribes' do
        let(:scribes) { DS::TeiXml.extract_scribes_as_recorded tei_xml }
        it 'extracts an scribe' do
          expect(scribes).to include 'Scribe One'
        end

        it 'extracts all scribes' do
          expect(scribes.size).to eq 2
        end
      end

      context 'extract_scribes_agr' do
        let(:scribes) { DS::TeiXml.extract_scribes_as_recorded tei_xml }
        let(:scribes_agr) { DS::TeiXml.extract_scribes_as_recorded_agr tei_xml }

        it 'extracts an scribe vernacular name' do
          expect(scribes_agr).to include 'Scribe One Vernacular'
        end

        it 'extracts nil when no vernacular name is present' do
          expect(scribes_agr).to include nil
        end

        it 'extracts as many vernacular names/slots as names' do
          expect(scribes_agr.size).to eq scribes.size
        end
      end
    end
  end

  context 'extract_acknowledgments' do
    let(:tei_xml) {
      openn_tei %q{<?xml version='1.0' encoding='UTF-8'?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title>Description of Free Library of Philadelphia, Widener 3: Book of Hours, Use of Sarum ("The John Browne Hours")</title>
              <respStmt>
                <resp>contributor</resp>
                <persName>Contributor 1</persName>
              </respStmt>
              <respStmt>
                <resp>contributor</resp>
                <persName>Contributor 2</persName>
              </respStmt>
              <respStmt>
                <resp>cataloger</resp>
                <persName>Cataloger 1</persName>
              </respStmt>
              <respStmt>
                <resp>cataloger</resp>
                <persName>Cataloger 2</persName>
              </respStmt>
              <funder>The Funder</funder>
            </titleStmt>
        </fileDesc>
      </TEI>
      }
    }

    let(:acknowledgments) { DS::TeiXml.extract_acknowledgments tei_xml }
    let(:catalogers) {
      ["Cataloger: Cataloger 1", "Cataloger: Cataloger 2"]
    }
    let(:contributors) {
      ["Contributor: Contributor 1", "Contributor: Contributor 2"]
    }

    it 'extracts catalogers' do
      expect(acknowledgments).to include "Cataloger: Cataloger 1"
    end

    it 'returns all catalogers' do
      expect(acknowledgments.grep %r{Cataloger}).to eq catalogers
    end

    it 'extracts contributors' do
      expect(acknowledgments).to include "Contributor: Contributor 1"
    end

    it 'returns all contributors' do
      expect(acknowledgments.grep %r{Contributor}).to eq contributors
    end

    it 'extracts a funder' do
      expect(acknowledgments).to include "Funder: The Funder"
    end
  end

  context 'titles' do
    let(:tei_xml) {
      openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <sourceDesc>
                <msDesc>
                  <msContents>
                    <summary>Clear copy of Ibn Hishām's grammar compendium. Two leaves have been sliced horizontally and are missing approximately the last 6 lines on each side (f. 11-12).</summary>
                    <textLang mainLang="ara">Arabic</textLang>
                    <msItem>
                      <title>Qaṭr al-nadā wa-ball al-ṣadā.</title>
                      <title type="vernacular">قطر الندا وبل الصدا</title>
                      <title>Second title</title>
                    </msItem>
                  </msContents>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>}
    }

    let(:titles) {
      DS::TeiXml.extract_titles_as_recorded tei_xml
    }

    let(:titles_agr) {
      DS::TeiXml.extract_titles_as_recorded_agr tei_xml
    }

    let(:recon_titles) {
      DS::TeiXml.extract_recon_titles tei_xml
    }

    context 'extract_title_as_recorded' do
      it 'extracts titles' do
        expect(titles).to eq ['Qaṭr al-nadā wa-ball al-ṣadā.', 'Second title']
      end

      it 'extracts all non-vernacular titles' do
        expect(titles).not_to include 'قطر الندا وبل الصدا'
      end
    end

    context 'extract_title_as_recorded_agr' do

      it 'extracts vernacular titles' do
        expect(titles_agr).to eq ['قطر الندا وبل الصدا', nil]
      end

      it 'returns a equal number of titles and titles agr' do
        expect(titles_agr.size).to eq titles.size
      end
    end

    context 'extract_recon_titles' do
      let(:expected_recon_titles) {
        [
          ['Qaṭr al-nadā wa-ball al-ṣadā.', 'قطر الندا وبل الصدا', nil, nil],
          ['Second title', nil, nil, nil]
        ]
      }
      it 'returns paired titles' do
        expect(recon_titles).to eq(expected_recon_titles)
      end
    end

  end

  context 'extract_physical_description' do
    let(:tei_xml) {
      openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <sourceDesc>
                <msDesc>
                  <physDesc>
                    <objectDesc>
                      <supportDesc material="parchment">
                        <support>
                          <p>Parchment</p>
                        </support>
                        <extent>153; 225 x 165 mm bound to 241 x 172 mm</extent>
                      </supportDesc>
                    </objectDesc>
                  </physDesc>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>
      }
    }

    let(:phys_desc) { DS::TeiXml.extract_physical_description tei_xml }

    it 'includes the extent' do
      expect(phys_desc).to have_item_matching /Extent: 153; 225 x 165 mm bound to 241 x 172 mm/
    end

    it 'includes the support' do
      expect(phys_desc).to have_item_matching /parchment/
    end

    it 'includes a formatted string' do
      expect(phys_desc).to eq ['Extent: 153; 225 x 165 mm bound to 241 x 172 mm; parchment']
    end

    context 'when extent is blank' do
      let(:tei_xml) {
        openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
          <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
              <fileDesc>
                <sourceDesc>
                  <msDesc>
                    <physDesc>
                      <objectDesc>
                        <supportDesc material="parchment">
                          <support>
                            <p>Parchment</p>
                          </support>
                      </objectDesc>
                    </physDesc>
                  </msDesc>
                </sourceDesc>
              </fileDesc>
            </teiHeader>
          </TEI>
        }
      }

      it 'returns the formatted extent' do
        expect(phys_desc).to eq ['Parchment']
      end
    end

    context "when support is blank" do
      let(:tei_xml) {
        openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
          <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
              <fileDesc>
                <sourceDesc>
                  <msDesc>
                    <physDesc>
                      <objectDesc>
                        <supportDesc material="parchment">
                          <extent>153; 225 x 165 mm bound to 241 x 172 mm</extent>
                        </supportDesc>
                      </objectDesc>
                    </physDesc>
                  </msDesc>
                </sourceDesc>
              </fileDesc>
            </teiHeader>
          </TEI>
        }
      }

      it 'returns the extent' do
        expect(phys_desc).to eq ['Extent: 153; 225 x 165 mm bound to 241 x 172 mm']
      end
    end

    context 'when extent and support are blank' do
      let(:tei_xml) {
        openn_tei %q{<?xml version="1.0" encoding="UTF-8"?>
          <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
              <fileDesc>
                <sourceDesc>
                  <msDesc>
                    <physDesc>
                      <objectDesc>
                        <supportDesc material="parchment">
                        </supportDesc>
                      </objectDesc>
                    </physDesc>
                  </msDesc>
                </sourceDesc>
              </fileDesc>
            </teiHeader>
          </TEI>
        }
      }

      it 'returns blank' do
        expect(phys_desc).to eq ['']
      end
    end

    context 'extract_material_as_recorded' do
      let(:material) { DS::TeiXml.extract_material_as_recorded tei_xml }

      it 'returns the support material' do
        expect(material).to eq 'Parchment'
      end
    end
  end

  context 'holding information' do
    let(:tei_xml) {
      openn_tei %q{<?xml version='1.0' encoding='UTF-8'?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <sourceDesc>
                <msDesc>
                  <msIdentifier>
                    <country>United States</country>
                    <settlement>Philadelphia</settlement>
                    <repository>Free Library of Philadelphia</repository>
                    <collection>Widener Collection</collection>
                    <idno type="call-number">Widener 3</idno>
                    <altIdentifier type="bibid">
                        <idno>abc1234</idno>
                    </altIdentifier>
                    <altIdentifier type="resource">
                      <idno>http://example.com/</idno>
                    </altIdentifier>
                  </msIdentifier>
                 </msDesc>
              </sourceDesc>
            </fileDesc>
          </TEI>
      }
    }

    context 'extract_holding_institution' do
      let(:holding_institution) { DS::TeiXml.extract_holding_institution tei_xml }

      it 'extracts the holding institution' do
        expect(holding_institution).to eq 'Free Library of Philadelphia'
      end
    end

    context 'extract_holding_institution_id_nummber' do
      let(:id_number) { DS::TeiXml.extract_holding_institution_id_nummber tei_xml }

      it 'extracts the holding institution id number' do
        expect(id_number).to eq 'abc1234'
      end
    end

    context 'extract_shelfmark' do
      let(:shelfmark) { DS::TeiXml.extract_shelfmark tei_xml }

      it 'extracts the shelfmark' do
        expect(shelfmark).to eq 'Widener 3'
      end
    end

    context 'extract_link_to_record' do
      let(:url) { DS::TeiXml.extract_link_to_record tei_xml }

      it 'extracts institution url' do
        expect(url).to eq 'http://example.com/'
      end
    end
  end

  context 'history' do
    let(:tei_xml) {
      openn_tei %q{<?xml version='1.0' encoding='UTF-8'?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <teiHeader>
            <fileDesc>
              <sourceDesc>
                <msDesc>
                  <history>
                    <origin>
                      <origDate notBefore="1450" notAfter="1475"/>
                      <p>Third quarter of the 15th century</p>
                      <origPlace>Flanders</origPlace>
                    </origin>
                    <provenance>Made for John Browne the Younger (d. 1476) and Agnes Browne of Stamford, Lincolnshire, England, 1460-1470; "Tho. Rosary," on flyleaf, c. 1720; "The gift of [Margaret] Lady Ayloffe [1704(?)-1797] to John Topham [1746-1803], Esq. May the 9th 1783," inside front cover; Sir Henry St. John Mildmay of Dogmersfield, Hampshire, England (bookplate of Dogmersfield Library on front flyleaf), c. 1820; his sale, Sotheby's, London, April 18-20, 1907, no. 6; Quaritch, London, 1907; P.A.B. Widener, Philadelphia; Joseph E. Widener, Philadelphia, 1915; given by his children, Josephine Widener Wichfeld and Peter A.B. Widener, to the Free Library of Philadelphia in 1944, in memory of their father</provenance>
                  </history>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
         </TEI>
      }
    }

    context 'extract_production_place' do
      let(:place) { DS::TeiXml.extract_production_places_as_recorded tei_xml }

      it 'extracts the place of production' do
        expect(place).to eq ['Flanders']
      end
    end

    context 'extract_production_date' do
      let(:date) { DS::TeiXml.extract_production_date_as_recorded tei_xml }

      it 'extracts the date of production' do
        expect(date).to eq ['1450-1475']
      end
    end
  end
end
