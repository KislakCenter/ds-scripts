# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Source::MarcXML do

  let(:source_dir) { fixture_path 'marc_xml' }
  let(:source_path) { File.join source_dir, '9951865503503681_marc.xml' }
  it_behaves_like 'a source cache implementation'

  let(:subject) { described_class.new }
  context '#load_source' do

    let(:parsed_source) { subject.load_source source_path }

    it 'loads the source' do
      expect(parsed_source).to be_a Nokogiri::XML::Document
    end

    it 'removes the namespace' do
      expect(parsed_source.namespaces).to be_empty
    end
  end

end
