# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::DsCsvIdValidator' do

  let(:subject) { DS::Manifest::DsCsvIdValidator.new }
  let(:source_dir) { fixture_path 'ds_csv' }
  let(:source_path) { File.join source_dir, 'ucriverside-dscsv.csv' }
  let(:id) { 'BP128.57 .A2 1700z' }
  let(:id_location) { 'Shelfmark' }
  it_behaves_like 'a source cache implementation'


  it_behaves_like 'a manifest id validator'

end
