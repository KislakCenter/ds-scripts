# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Converter::Converter do

  let(:marc_xml_dir) { fixture_path 'marc_xml' }
  let(:manifest_path) { File.join marc_xml_dir, 'manifest.csv'  }
  let(:manifest) { DS::Manifest::Manifest.new manifest_path, marc_xml_dir }
  let(:converter) { DS::Converter::Converter.new manifest }
  let(:entry) { manifest.first }

  context '#initialize' do
    it 'creates a new DS::Converter::Converter' do
      expect(
        DS::Converter::Converter.new manifest
      ).to be_a DS::Converter::Converter
    end
  end

  context '#source_file_path' do
    let(:marc_file_path) { File.join marc_xml_dir, entry.filename }

    it 'returns the full path to the source file' do
      expect(converter.source_file_path entry).to eq marc_file_path
    end
  end

  context '#find_or_create_mapper' do
    it 'gets a MarcMapper' do
      expect(
        converter.find_or_create_mapper(entry, Time.now)
      ).to be_a DS::Mapper::MarcMapper
    end
  end

  context '#convert' do
    let(:mapper) {
      DS::Mapper::MarcMapper.new(
        source_dir: marc_xml_dir,
        timestamp: Time.now
      )
    }

    it 'yields a hash' do
      # Running BaseMapper#map_record is slow, and that method is tested
      # elsewhere; here, mock Converter#find_or_create_mapper and
      # BaseMapper#map_record to optimize the test
      allow(converter).to receive(:find_or_create_mapper).and_return(mapper)
      allow(mapper).to receive(:map_record).and_return({})

      expect { |b| converter.convert &b }.to yield_successive_args({}, {})
    end

    it 'returns an array' do
      allow(converter).to receive(:find_or_create_mapper).and_return(mapper)
      allow(mapper).to receive(:map_record).and_return({ a: 1})

      expect(converter.convert).to be_an Array
    end

    it 'returns an array of hashes' do
      allow(converter).to receive(:find_or_create_mapper).and_return(mapper)
      allow(mapper).to receive(:map_record).and_return({ a: 1})

      expect(converter.convert).to include({ a: 1 })
    end
  end

  context '#mapper_cache' do
    let(:timestamp) { Time.now }
    let(:mapper) { DS::Mapper::MarcMapper.new(source_dir: marc_xml_dir, timestamp: timestamp) }
    it '#find_or_create_mapper calls #create_mapper once for the same mapper' do
      expect(converter).to receive(:create_mapper).exactly(:once)
      converter.find_or_create_mapper entry, timestamp
      converter.find_or_create_mapper entry, timestamp
    end
  end
end
