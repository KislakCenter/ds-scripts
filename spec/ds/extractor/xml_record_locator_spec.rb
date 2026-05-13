# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Extractor::XmlRecordLocator do

  it 'is a BaseRecordLocator' do
    xml_record_locator = DS::Extractor::XmlRecordLocator.new
    expect(xml_record_locator).to be_a DS::Extractor::BaseRecordLocator
  end
  context 'tries to locate a MARC xml record' do
    let(:marc_xml) { Nokogiri::XML(File.read(fixture_path 'marc_xml/9949533433503681_marc.xml')) }
    let(:lookup_value) { "9949533433503681" }
    let(:lookup_value_location) { "//record[./controlfield[@tag='001' and ./text() = 'ID_PLACEHOLDER']]" }

    it 'locates a present MARC xml record' do
      xml_record_locator = DS::Extractor::XmlRecordLocator.new
      record = xml_record_locator.locate_record(marc_xml, lookup_value, lookup_value_location)
      expect(record).to be_present
    end
  end

  context 'tries to locate a DS METS xml record' do
    let(:mets_xml) { Nokogiri::XML(File.read(fixture_path 'ds_mets_xml/ds_mets-nelson-atkins-kg40.xml'))}
    let(:lookup_value) { "KG 40" }
    let(:lookup_value_location) { "/mets:mets[./mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type = 'local' and ./text() = 'ID_PLACEHOLDER']]" }
    it 'locates a present DS METS xml record' do
      xml_record_locator = DS::Extractor::XmlRecordLocator.new
      record = xml_record_locator.locate_record(mets_xml, lookup_value, lookup_value_location)
      expect(record).to be_present
    end
  end

  context 'tries to locate a TEI xml record' do
    let(:tei_xml) { Nokogiri::XML(File.read(fixture_path 'tei_xml/lewis_o_031_TEI.xml')) }
    let(:lookup_value) { "Lewis O 31" }
    let(:lookup_value_location) { "/TEI[./teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno/text() = 'ID_PLACEHOLDER']" }
    it 'locates a present DS METS xml record' do
      xml_record_locator = DS::Extractor::XmlRecordLocator.new
      record = xml_record_locator.locate_record(tei_xml, lookup_value, lookup_value_location)
      expect(record).to be_present
    end
  end

end
