# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Util::SourceCache do

  class SourceCacheTest
    include DS::Util::SourceCache

    def open_source arg
      @counter ||= 0
      "opened #{@counter += 1}"
    end
  end

  let(:subject) { SourceCacheTest.new }

  let(:source_path)  { "some/path"}
  it_behaves_like "a source cache implementation"

  context "#open_source" do
    it "returns the expected source" do
      expect(subject.open_source "source").to eq "opened 1"
    end
  end

  context "#find_or_open_source" do
    let(:first_source) { "first source" }
    let(:second_source) { "second source" }
    let(:third_source) { "third source" }

    let(:test_source) { SourceCacheTest.new }
    before(:each) do
      test_source = SourceCacheTest.new
      test_source.open_source first_source   # => "opened 1"
      test_source.open_source second_source  # => "opened 2"
      test_source.open_source third_source   # => "opened 3"
    end

    it "returns the first source" do
      expect(test_source.find_or_open_source first_source).to eq "opened 1"
      expect(test_source.find_or_open_source second_source).to eq "opened 2"
      expect(test_source.find_or_open_source third_source).to eq "opened 3"
    end
  end
end
