# frozen_string_literal: true

module Recon
  class ReconManager

    attr_accessor :out_dir
    attr_accessor :recon_builder

    def initialize recon_builder:, out_dir:
      @out_dir = out_dir
      @recon_builder = recon_builder
    end

  end
end
