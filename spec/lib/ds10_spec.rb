require 'spec_helper'
require 'nokogiri'

describe DS::DS10 do

  # let(:na_ds_mets) {̋̋ fixture_path 'ds_mets-nelson-atkins-kg40.xml' }
  let(:na_ds_mets) { fixture_path 'ds_mets-nelson-atkins-kg40.xml' }
  # ds_mets_csl_sutro_collection_ms_05.xml -- 2 parts, no provenance
  let(:csl_ds_mets) { fixture_path 'ds_mets_csl_sutro_collection_ms_05.xml' }
  let(:ds_names_mets) { fixture_path 'ds_mets_names.xml' }
  let(:ds_docket_mets) { fixture_path 'ds_mets_docket.xml' }

  let(:na_ds_xml) { File.open(na_ds_mets) { |f| Nokogiri::XML f } }
  let(:csl_ds_xml) { File.open(csl_ds_mets) { |f| Nokogiri::XML f } }
  let(:ds_names_xml) { File.open(ds_names_mets) { |f| Nokogiri::XML f } }
  let(:ds_docket_xml) { File.open(ds_docket_mets) { |f| Nokogiri::XML f } }

  let(:all_notes) {
    [
      'Manuscript note: Untyped note.',
      'Bibliography: Bibliography.',
      'One leaf: Untyped part note.',
      'One leaf: Untyped text note.',
      'Status of text, One leaf: Condition note.',
      'f. 1r: Untyped page note.',
      'Incipit, One leaf: Text content note.',
      'Explicit, One leaf: Text abstract.',
      'Incipit, f. 1v: Page content note.',
      'Explicit, f. 1v: Page abstract.',
    ].sort
  }

  let(:all_phys_descs) {
    [
      'Binding: Not bound.',
      'Figurative details, One leaf: Physical details note.',
      'Other decoration, One leaf: Physical description note.',
      'Number of scribes, One leaf: number of scribes.',
      'Script, One leaf: Script note.',
      'Music, One leaf: Medium note.',
      'Layout, One leaf: Technique note.',
      'Watermarks, One leaf: Marks note.',
    ]
  }

  context "notes" do
    context 'extract_ms_note' do
      it 'formats an untyped ms note' do
        expect(DS::DS10.extract_ms_note na_ds_xml).to include 'Manuscript note: Untyped note'
      end

      it 'formats a bibliography note' do
        expect(DS::DS10.extract_ms_note na_ds_xml).to include 'Bibliography: Bibliography'
      end
    end

    context 'extract_part_note' do
      it 'formats an untyped part note' do
        expect(DS::DS10.extract_part_note na_ds_xml).to include 'One leaf: Untyped part note'
      end
    end

    context 'extract_text_note' do
      it 'formats an untyped text note' do
        expect(DS::DS10.extract_text_note na_ds_xml).to include 'One leaf: Untyped text note'
      end

      it 'formats a condition note' do
        expect(DS::DS10.extract_text_note na_ds_xml).to include 'Status of text, One leaf: Condition note'
      end

      it 'formats an incipit' do
        expect(DS::DS10.extract_text_note na_ds_xml).to include 'Incipit, One leaf: Text content note'
      end

      it 'formats an explicit' do
        expect(DS::DS10.extract_text_note na_ds_xml).to include 'Explicit, One leaf: Text abstract'
      end

    end

    context 'extract_name' do
      it 'returns "" when there are no scribes' do
        # expect(DS::DS10.extract_name csl_ds_xml, *%w{ scribe [scribe] }).to be_empty
        expect(DS::DS10.extract_scribe csl_ds_xml).to be_empty
      end

      it 'returns the scribe names' do
        # actual = DS::DS10.extract_name ds_names_xml, *%w{ scribe [scribe] }
        actual = DS::DS10.extract_scribe ds_names_xml
        expect(actual.sort).to eq ['Bracketed scribe', 'Part 1 scribe','Part 2 scribe']
      end

      it 'returns the artist names' do
        # actual = DS::DS10.extract_name ds_names_xml, *%w{ artist [artist] illuminator }
        actual = DS::DS10.extract_artist ds_names_xml
        expect(actual.sort).to eq ['Illuminator artist', 'Part 1 artist', 'Part 2 artist']
      end

      it 'returns the author names' do
        # actual = DS::DS10.extract_name ds_names_xml, *%w{ author [author] }
        actual = DS::DS10.extract_author ds_names_xml
        expect(actual.sort).to eq ['Bracketed author','Corporate author', 'Personal author 1', 'Personal author 2']
      end
    end

    context 'extract_docket' do
      it 'finds two dockets' do
        actual = DS::DS10.extract_docket ds_docket_xml
        expected = [ 'Docket: Docket abstract 1', 'Docket: Docket abstract 2' ]
        expect(actual.sort).to eq expected
      end

    end

    context 'extract_page_note' do
      it 'formats an untyped page note' do
        expect(DS::DS10.extract_page_note na_ds_xml).to include 'f. 1r: Untyped page note'
      end

      it 'formats an incipit' do
        expect(DS::DS10.extract_page_note na_ds_xml).to include 'Incipit, f. 1v: Page content note'
      end

      it 'formats an explicit' do
        expect(DS::DS10.extract_page_note na_ds_xml).to include 'Explicit, f. 1v: Page abstract'
      end

    end

    context 'extract_note' do
      it 'formats all the notes' do
        notes = DS::DS10.extract_note na_ds_xml
        all_notes.each do |note|
          expect(notes).to include note
        end
      end

      it 'does not include "lang:" notes' do
        notes = DS::DS10.extract_note na_ds_xml
         expect(notes.grep /lang: Latin/i).to be_empty
      end

      it 'flags a long ms note' do
        notes = DS::DS10.extract_note na_ds_xml
        expect(notes.grep /^SPLIT.*Long MS note/).not_to be_empty
      end

      it 'flags a long part note' do
        notes = DS::DS10.extract_note na_ds_xml
        expect(notes.grep /^SPLIT.*Long part note/).not_to be_empty
      end

      it 'flags a long text note' do
        notes = DS::DS10.extract_note na_ds_xml
        expect(notes.grep /^SPLIT.*Long text note/).not_to be_empty
      end

      it 'flags a page ms note' do
        notes = DS::DS10.extract_note na_ds_xml
        expect(notes.grep /^SPLIT.*Long page note/).not_to be_empty
      end

      it 'includes any dockets' do
        notes = DS::DS10.extract_note ds_docket_xml
        expect(notes.grep(/^Docket/).size).to eq 2
      end
    end
  end

  context 'physical description' do
    context 'extract_ms_phys_desc' do
      it 'formats a binding note' do
        expect(DS::DS10.extract_ms_phys_desc na_ds_xml).to include 'Binding: Not bound'
      end
    end

    context 'extract_part_phys_desc' do
      it 'formats a physical details note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Figurative details, One leaf: Physical details note'
      end

      it 'formats a physical description other decoration note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Other decoration, One leaf: Physical description note'
      end

      it 'formats a physical description number of scribes note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Number of scribes, One leaf: number of scribes'
      end

      it 'formats a script note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Script, One leaf: Script note'
      end

      it 'formats a medium note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Music, One leaf: Medium note'
      end

      it 'formats a technique note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Layout, One leaf: Technique note'
      end

      it 'formats a marks note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Watermarks, One leaf: Marks note'
      end

    end # context: extract_part_phys_desc

    context 'extract_physical_description' do
      it 'formats all the phys desc notes' do
        descs = DS::DS10.extract_physical_description na_ds_xml
        all_phys_descs.each do |desc|
          expect(descs).to include desc
        end
      end

      it 'flags a long part ms description' do
        descs = DS::DS10.extract_physical_description na_ds_xml
        expect(descs.grep /^SPLIT.*Long MS description/).not_to be_empty, "No SPLIT desc present"
      end

      it 'flags a long part physical description' do
        descs = DS::DS10.extract_physical_description na_ds_xml
        expect(descs.grep /^SPLIT.*Long part description/).not_to be_empty, "No SPLIT desc present"
      end
    end

    context 'extract_acknowledgements' do
      it 'flags a long acknowledgement' do
        acks = DS::DS10.extract_acknowledgements na_ds_xml
        expect(acks.grep /SPLIT.*Long acknowledgement/).not_to be_empty, "Expected acknowledgement marked SPLIT "
      end

      it 'formats an ms acknowledgement' do
        expect(DS::DS10.extract_acknowledgements na_ds_xml).to have_item_matching /^MS acknowledgement/
      end

      it 'formats a part acknowledgement' do
        expect(DS::DS10.extract_acknowledgements na_ds_xml).to have_item_matching /^One leaf: Part acknowledgement/
      end

      it 'formats a text acknowledgement' do
        expect(DS::DS10.extract_acknowledgements na_ds_xml).to have_item_matching /^One leaf: Text acknowledgement/
      end

      it 'formats a page acknowledgement' do
        expect(DS::DS10.extract_acknowledgements na_ds_xml).to have_item_matching /^f. 1r: Page acknowledgement/
      end
    end
  end # context: physical description

  context 'extract_ownership' do
    it 'flags a long ownership note' do
      expect(DS::DS10.extract_ownership na_ds_xml).to have_item_matching /^SPLIT.*Long ownership/
    end
  end
end