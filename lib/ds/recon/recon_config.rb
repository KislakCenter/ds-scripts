# frozen_string_literal: true

module Recon
  class ReconConfig
    attr_accessor :method_name
    attr_accessor :item_type
    attr_accessor :columns
    attr_accessor :delimiter_map

    def initialize(
      method_name:, item_type:, columns:, delimiter_map: {})
      @method_name = method_name
      @item_type = item_type
      @columns = columns
      @delimiter_map = delimiter_map
    end
  end
end
