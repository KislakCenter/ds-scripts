# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Recon::Type::Splits do
  skips  =  %i{ balanced_columns }
  it_behaves_like 'a recon type class', skips
end
