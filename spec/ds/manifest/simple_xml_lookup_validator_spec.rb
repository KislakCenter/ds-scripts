# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Manifest::SimpleXmlLookupValidator' do

  let(:subject) { DS::Manifest::SimpleXmlLookupValidator.new DS::Source::TeiXML.new }
  let(:source_dir) { fixture_path 'tei_xml' }
  let(:source_path) { File.join source_dir, 'lewis_o_031_TEI.xml' }
  let(:lookup_value) { 'Lewis O 31' }
  let(:lookup_value_location) { '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno' }
  it_behaves_like 'a manifest lookup validator'

end
