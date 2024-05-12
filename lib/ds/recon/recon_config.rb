# frozen_string_literal: true

module Recon
  class ReconConfig
    attr_accessor :method_name
    attr_accessor :klass

    def initialize(method_name:, klass:)
      @method_name = method_name
      @klass = klass
    end
  end
end
