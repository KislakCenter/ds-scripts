# frozen_string_literal: true

require 'rspec'

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
end