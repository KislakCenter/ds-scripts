# frozen_string_literal: true

# Initial draft of this code generated by Doug Emery using GPT-3.5
# Date: 2023-12-17

require 'spec_helper'

module DS
  module Extractor
    RSpec.describe Name do
      let(:name) do
        described_class.new(
          as_recorded: 'John Doe',
          role: 'Author',
          vernacular: 'Doe, John',
          ref: '12345'
        )
      end

      context '#as_recorded' do
        it 'should have a readable as_recorded attribute' do
          expect(name.as_recorded).to eq('John Doe')
        end

        it 'should have a writable as_recorded attribute' do
          name.as_recorded = 'Jane Doe'
          expect(name.as_recorded).to eq('Jane Doe')
        end
      end

      context '#role' do
        it 'should have a readable role attribute' do
          expect(name.role).to eq('Author')
        end

        it 'should have a writable role attribute' do
          name.role = 'Editor'
          expect(name.role).to eq('Editor')
        end
      end

      context '#vernacular' do
        it 'should have a readable vernacular attribute' do
          expect(name.vernacular).to eq('Doe, John')
        end

        it 'should have a writable vernacular attribute' do
          name.vernacular = 'Doe, Jane'
          expect(name.vernacular).to eq('Doe, Jane')
        end
      end

      context '#ref' do
        it 'should have a readable ref attribute' do
          expect(name.ref).to eq('12345')
        end

        it 'should have a writable ref attribute' do
          name.ref = '67890'
          expect(name.ref).to eq('67890')
        end
      end

      context '#initialize' do
        it 'should initialize the name with the given attributes' do
          expect(name.as_recorded).to eq('John Doe')
          expect(name.role).to eq('Author')
          expect(name.vernacular).to eq('Doe, John')
          expect(name.ref).to eq('12345')
        end

        it 'should be an instance of DS::Extractor::Name' do
          expect(name).to be_an_instance_of(DS::Extractor::Name)
        end
      end

      context '#to_a' do
        it 'should return an array representation of the attributes' do
          expect(name.to_a).to eq(['John Doe', 'Author', 'Doe, John', '12345'])
        end
      end

      context '#to_h' do
        it 'should return a hash representation of the attributes' do
          expect(name.to_h).to eq({
                                    as_recorded: 'John Doe',
                                    role: 'Author',
                                    vernacular: 'Doe, John',
                                    ref: '12345'
                                  })
        end
      end
    end
  end
end