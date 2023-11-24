# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::Mapper' do

  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:timestamp) { Time.now }
  let(:mapper) { DS::Mapper::Mapper.new marc_xml_dir, timestamp }
  let(:entry) { Object.new }

  context 'initialize' do
    it 'creates a new mapper' do
      expect(
        DS::Mapper::Mapper.new marc_xml_dir, timestamp
      ).to be_a DS::Mapper::Mapper
    end
  end

  context 'attributes' do
    context '#source_dir' do
      it 'is the source_dir' do
        expect(mapper.source_dir).to eq marc_xml_dir
      end
    end

    context '#timestamp' do
      it 'is the timestamp' do
        expect(mapper.timestamp).to eq timestamp
      end
    end
  end

  context '#extract_record' do
    it 'is a Mapper method' do
      expect(mapper.methods).to include :extract_record
    end

    it 'is not implemented' do
      expect {
        mapper.extract_record entry
      }.to raise_exception NotImplementedError
    end
  end

  context '#map_record' do
    it 'is a Mapper method' do
      expect(mapper.methods).to include :map_record
    end

    it 'is not implemented' do
      expect {
        mapper.map_record entry
      }.to raise_exception NotImplementedError
    end
  end
end