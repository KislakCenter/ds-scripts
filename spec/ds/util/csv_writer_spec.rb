# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DS::Util::CSVWriter do

  let(:headers) { %i{ a b c } }
  let(:rows) {
    [
      { a: 1,  b: 2, c: 3},
      { a: 4,  b: 5, c: 6},
    ]
  }
  let(:outfile) { Tempfile.new }
  let(:subject) {
    DS::Util::CSVWriter.new headers: headers, outfile: outfile
  }
  let(:outfile_content) {
    <<~HEREDOC
      a,b,c
      1,2,3
      4,5,6
    HEREDOC
  }

  context '#initialize' do
    it 'is a CSVWriter' do
      expect(
        DS::Util::CSVWriter.new headers: headers, outfile: outfile
      ).to be_a DS::Util::CSVWriter
    end

    context '#write rows' do

      it 'writes all the rows' do
        subject.write rows
        expect(open(outfile).read).to eq outfile_content
      end
    end

    context '#write with block' do
      it 'writes all the rows' do
        subject.write do |csv|
          rows.each { |row| csv << row }
        end
        expect(open(outfile).read).to eq outfile_content
      end
    end
  end
end
