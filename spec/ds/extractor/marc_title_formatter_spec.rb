# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'DS::Extractor::MarcTitleFormatter' do

  describe '#xpath' do
    let(:marc_title_formatter) { DS::Extractor::MarcTitleFormatter.new }

    context 'one subfield in codes' do
      before { allow(marc_title_formatter).to receive(:codes).and_return(%w[a]) }

      it 'returns "subfield[@code=\'a\']"' do
        expect(marc_title_formatter.xpath).to eq "subfield[@code='a']"
      end
    end

    context 'two subfields in codes' do
      before { allow(marc_title_formatter).to receive(:codes).and_return(%w[a b]) }

      it 'returns "subfield[@code=\'a\' or @code=\'b\']"' do
        expect(marc_title_formatter.xpath).to eq "subfield[@code='a' or @code='b']"
      end
    end

    context 'three subfields in codes' do
      before { allow(marc_title_formatter).to receive(:codes).and_return(%w[a b c]) }

      it 'returns "subfield[@code=\'a\' or @code=\'b\' or @code=\'c\']"' do
        expect(marc_title_formatter.xpath).to eq "subfield[@code='a' or @code='b' or @code='c']"
      end
    end

    context 'no codes' do
      before { allow(marc_title_formatter).to receive(:codes).and_return(%w[]) }

      it 'returns "subfield"' do
        expect(marc_title_formatter.xpath).to eq "subfield"
      end
    end
  end
end
