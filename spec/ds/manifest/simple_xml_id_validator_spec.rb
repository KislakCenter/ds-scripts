# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::SimpleXmlIdValidator' do

  let(:subject) { DS::Manifest::SimpleXmlIdValidator.new DS::Source::TeiXML.new }
  let(:source_dir) { fixture_path 'tei_xml' }
  let(:source_path) { File.join source_dir, 'lewis_o_031_TEI.xml' }
  let(:id) { 'Lewis O 31' }
  let(:id_location) { '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno' }
  it_behaves_like 'a manifest id validator'

end
