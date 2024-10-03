# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Recon::Type::ReconType' do


  context '.get_key_values' do
    let(:recon_type) { Recon::Type::Titles }
    let(:row) {
      {
        :title_as_recorded=>"Title as recorded",
        :title_as_recorded_agr=>nil,
        :uniform_title_as_recorded=>"Uniform title",
        :uniform_title_as_recorded_agr=>nil,
        :authorized_label=>"Roman de Lancelot",
        :ds_qid=>nil}
    }
    let(:expected_key_values) {
      ["Title as recorded", 'Uniform title']
    }
    it 'returns the key values' do
      expect(recon_type.get_key_values(row)).to eq expected_key_values
    end
  end
end
