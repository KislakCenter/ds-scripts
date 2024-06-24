# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Source::DSMetsXML do

  let(:source_dir) { fixture_path 'ds_mets_xml' }
  let(:source_path) { File.join source_dir, 'ds_mets-nelson-atkins-kg40.xml' }
  it_behaves_like 'a source cache implementation'

  let(:subject) { described_class.new }
  context '#load_source' do

    let(:parsed_source) { subject.load_source source_path }

    it 'loads the source' do
      expect(parsed_source).to be_a Nokogiri::XML::Document
    end

    it 'removes the namespace' do
      expect(parsed_source.namespaces).not_to be_empty
    end
  end

end
