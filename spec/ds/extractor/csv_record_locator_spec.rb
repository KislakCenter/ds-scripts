# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe DS::Extractor::CsvRecordLocator do
  let(:locator) { described_class.new }

  it 'is a BaseRecordLocator' do
    csv_record_locator = described_class.new
    expect(csv_record_locator).to be_a DS::Extractor::BaseRecordLocator
  end

  context 'when it tries to locate a DS csv record' do
    let(:ds_csv) { CSV.open(fixture_path('ds_csv/ucriverside-dscsv.csv'), headers: true) }
    let(:lookup_value) { 'BP128.57 .A2 1700z' }
    let(:bad_lookup_value) { 'BP128.57 .A2 NOT IN SOURCE' }
    let(:lookup_value_location) { 'Shelfmark' }

    it 'locates a present DS csv record' do
      record = locator.locate_record(ds_csv, lookup_value, lookup_value_location)
      expect(record).to be_present
    end

    it 'does not locate a record when one is not present' do
      record = locator.locate_record(ds_csv, bad_lookup_value, lookup_value_location)
      expect(record).not_to be_present
    end
  end
end
