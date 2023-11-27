# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Mapper::BaseMapper' do

  let(:marc_xml_dir) { fixture_path 'marc_xml' }

  ##
  # Test implementations of the BaseMapper methods
  class TestMapper < DS::Mapper::BaseMapper
    def extract_record entry; {}; end

    def map_record entry; {}; end

    def open_source entry; {}; end
  end

  let(:timestamp) { Time.now }
  let(:base_mapper) {
    DS::Mapper::BaseMapper.new source_dir: marc_xml_dir, timestamp: timestamp
  }

  let(:test_mapper) {
    TestMapper.new source_dir: marc_xml_dir, timestamp: timestamp
  }

  let(:entry) { Object.new }

  context 'initialize' do
    it 'creates a new mapper' do
      expect(
        DS::Mapper::BaseMapper.new source_dir: marc_xml_dir, timestamp: timestamp
      ).to be_a DS::Mapper::BaseMapper
    end
  end

  context 'attributes' do
    context '#source_dir' do
      it 'is the source_dir' do
        expect(base_mapper.source_dir).to eq marc_xml_dir
      end
    end

    context '#timestamp' do
      it 'is the timestamp' do
        expect(base_mapper.timestamp).to eq timestamp
      end
    end
  end

  context '#extract_record' do
    it 'is a Mapper method' do
      expect(base_mapper.methods).to include :extract_record
    end

    it 'is not implemented' do
      expect {
        base_mapper.extract_record entry
      }.to raise_exception NotImplementedError
    end
  end

  context '#map_record' do
    it 'is a Mapper method' do
      expect(base_mapper.methods).to include :map_record
    end

    it 'is not implemented' do
      expect {
        base_mapper.map_record entry
      }.to raise_exception NotImplementedError
    end
  end

  context "#==" do
    let(:other_mapper) {
      DS::Mapper::BaseMapper.new source_dir: marc_xml_dir, timestamp: timestamp
    }

    it 'is not based on object ID' do
      expect(base_mapper).to eq other_mapper
    end

    it 'is commutative' do
      expect(other_mapper).to eq base_mapper
    end

    let(:test_mapper) {
      TestMapper.new(
        source_dir: base_mapper.source_dir,
        timestamp: base_mapper.timestamp
      )
    }

    it 'requires classes be the same' do
      expect(test_mapper).not_to eq base_mapper
    end
  end

  context "#source_cache" do
    # confirm caching works: create two entries with the same source
    # filename

    let(:entry1) {
      obj = Object.new
      obj.define_singleton_method(:filename) do; "some_file.xml"; end
      obj
    }

    let(:entry2) {
      obj = Object.new
      obj.define_singleton_method(:filename) do; "some_file.xml"; end
      obj
    }

    it '#find_or_open_source calls #open_source once for the same source' do
      expect(test_mapper).to receive(:open_source).exactly(:once)
      test_mapper.find_or_open_source entry1
      test_mapper.find_or_open_source entry2
    end
  end


end