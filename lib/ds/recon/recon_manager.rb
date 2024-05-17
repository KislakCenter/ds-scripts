# frozen_string_literal: true

module Recon
  class ReconManager

    attr_accessor :out_dir
    attr_accessor :recon_builder

    # Initialize the ReconManager.
    #
    # @param recon_builder [Recon::ReconBuilder] the recon builder instance
    # @param out_dir [String] the output directory path
    # @return [void]
    def initialize recon_builder:, out_dir:
      @out_dir = out_dir
      @recon_builder = recon_builder
    end

    def write_csv set_name:
      csv_writer = DS::Util::CSVWriter.new outfile: File.join(out_dir, "#{set_name}.csv")

    end
  end
end
