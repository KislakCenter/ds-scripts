# frozen_string_literal: true

require 'spec_helper'
require 'csv'

RSpec.describe DS::Extractor::CsvRecordLocator do

  it 'is a BaseRecordLocator' do
    csv_record_locator = DS::Extractor::CsvRecordLocator.new
    expect(csv_record_locator).to be_a DS::Extractor::BaseRecordLocator
  end

  context 'tries to locate a DS csv record' do
    let(:ds_csv) { CSV.open(fixture_path('ds_csv/ucriverside-dscsv.csv'), headers: true) }
    let(:lookup_value) { "BP128.57 .A2 1700z" }
    let(:lookup_value_location) { "Shelfmark" }

    it 'locates a present DS csv record' do
      csv_record_locator = DS::Extractor::CsvRecordLocator.new
      record = csv_record_locator.locate_record(ds_csv, lookup_value, lookup_value_location)
      expect(record).to be_present
    end
  end
end
