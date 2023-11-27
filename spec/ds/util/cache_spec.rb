# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DS::Util::Cache' do
  let(:cache) { DS::Util::Cache.new }

  context ".initialize" do

    it 'creates a cache' do
      expect(DS::Util::Cache.new).to be_a DS::Util::Cache
    end

    it 'creates a cache with a max_size' do
      expect(DS::Util::Cache.new.max_size).to be > 1
    end

    it 'creates an empty cache' do
      expect(DS::Util::Cache.new.items).to eq({})
    end
  end

  context '#get_or_add key, item' do
    let(:item) { "some item" }
    let(:key) { :some_key }

    let(:full_set_of_items) {
      items = {}
      cache.max_size.times { |i| items["key#{i}".to_sym] = "item #{i}" }
      items
    }

    it 'adds an item' do
      cache.get_or_add key, item
      expect(cache).to include key
    end

    it 'adds an item only once' do
      cache.get_or_add key, item
      cache.get_or_add key, item
      expect(cache.size).to eq 1
    end

    it 'adds 10 items' do
      full_set_of_items.each { |k,v| cache.get_or_add k, v }
      expect(cache.size).to eq cache.max_size
    end

    let(:full_cache) {
      full_set_of_items.each { |k,v| cache.get_or_add k, v }
      cache
    }

    it 'limits the cache to max size' do
      expect(full_cache.size).to eq full_cache.max_size
      key = :key9999
      expect(full_cache).not_to include key
      full_cache.get_or_add(key, "item 9999")
      expect(full_cache.size).to eq full_cache.max_size
    end

    it 'removes the first key when max size is exceeded' do
      first_key = full_cache.keys.first
      expect(cache).to include first_key
      new_key = :key9999
      new_item = "item 9999"
      expect(cache).not_to include new_key
      full_cache.get_or_add new_key, new_item
      expect(full_cache).to include new_key
      expect(full_cache).not_to include first_key
    end

  end
end