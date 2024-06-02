# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Manifest::MarcIdValidator do

  let(:subject) { DS::Manifest::MarcIdValidator.new }
  let(:source_dir) { fixture_path 'marc_xml' }
  let(:source_path) { File.join source_dir, 'multiple_marc_records.xml' }
  let(:id) { '9951865503503681' }
  let(:id_location) { 'controlfield[@tag="001"]' }


  it_behaves_like 'a manifest id validator'

  it_behaves_like 'a source cache implementation'
end
