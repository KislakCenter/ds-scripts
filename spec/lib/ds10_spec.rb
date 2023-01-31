require 'spec_helper'
require 'nokogiri'

describe DS::DS10 do

  # let(:na_ds_mets) {̋̋ fixture_path 'ds_mets-nelson-atkins-kg40.xml' }
  let(:na_ds_mets) { fixture_path 'ds_mets-nelson-atkins-kg40.xml' }

  let(:na_ds_xml) {
    File.open(na_ds_mets) { |f| Nokogiri::XML f }
  }

  let(:nd_ds_ms) { DS::DS10.find_ms na_ds_xml }

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
        all_notes.each do |note|
          expect(DS::DS10.extract_note na_ds_xml).to include note
        end
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

      it 'formats a physical description note' do
        expect(DS::DS10.extract_part_phys_desc na_ds_xml).to include 'Other decoration, One leaf: Physical description note'
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
        all_phys_descs.each do |desc|
          expect(DS::DS10.extract_physical_description na_ds_xml).to include desc
        end
      end
    end
  end # context: physical description
end