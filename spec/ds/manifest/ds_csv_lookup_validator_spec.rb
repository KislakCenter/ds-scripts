# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::DsCsvLookupValidator' do

  let(:subject) { DS::Manifest::DsCsvLookupValidator.new DS::Source::DSCSV.new }
  let(:source_dir) { fixture_path 'ds_csv' }
  let(:source_path) { File.join source_dir, 'ucriverside-dscsv.csv' }
  let(:lookup_value) { 'BP128.57 .A2 1700z' }
  let(:lookup_value_location) { 'Shelfmark' }

  it_behaves_like 'a manifest lookup validator'

end
