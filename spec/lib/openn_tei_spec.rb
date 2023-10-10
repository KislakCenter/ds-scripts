# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::OPennTEI' do
  before do
    # Do nothing
  end

  after do
    # Do nothing
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

    let(:notes) { DS::OPennTEI.extract_note tei_xml }

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

  context 'extract_authors_as_recorded' do
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
                        <persName type="authority">Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
                        <persName type="vernacular">يوسف بن شيخ محمد الجمالي.</persName>
                      </respStmt>
                      <respStmt>
                        <resp>former owner</resp>
                        <persName type="authority">Lewis, John Frederick, 1860-1932</persName>
                      </respStmt>
                      <respStmt>
                      <resp>donor</resp>
                        <persName type="authority">Lewis, Anne Baker, 1868-1937</persName>
                      </respStmt>
                    </msItem>
                  </msContents>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>}
    }

    let(:authors) { DS::OPennTEI.extract_authors_as_recorded tei_xml }
    it 'includes a persName[@type = "authority"]' do
      expect(authors).to include 'Ibn Hishām, ʻAbd Allāh ibn Yūsuf, 1309-1360'
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

    let(:bad_tei_xml) {
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
                        <persName type="glarg">Ibn Hishām, ʻAbd Allāh ibn Yūsuf, 1309-1360</persName>
                      </author>
                      <respStmt>
                      <resp>former owner</resp>
                        <persName type="authority">Jamālī, Yūsuf ibn Shaykh Muḥammad</persName>
                        <persName type="vernacular">يوسف بن شيخ محمد الجمالي.</persName>
                      </respStmt>
                      <respStmt>
                        <resp>former owner</resp>
                        <persName type="authority">Lewis, John Frederick, 1860-1932</persName>
                      </respStmt>
                      <respStmt>
                      <resp>donor</resp>
                        <persName type="authority">Lewis, Anne Baker, 1868-1937</persName>
                      </respStmt>
                    </msItem>
                  </msContents>
                </msDesc>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
        </TEI>}
    }

  end
end