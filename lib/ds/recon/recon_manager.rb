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
      @out_dir       = out_dir
      @recon_builder = recon_builder
    end

    # Write all recon CSV files.
    #
    # @return [void]
    def write_all_csvs
      Recon::RECON_TYPES.each do |recon_type|
        write_csv recon_type
      end
    end

    # Write a CSV file for a specific recon type.
    #
    # @param recon_type [Recon::ReconType] the type of reconciliation data
    # @return [void]
    def write_csv recon_type
      outfile = File.join out_dir, "#{recon_type.set_name}.csv"
      CSV.open(outfile, 'w+', headers: true) do |csv|
        csv << recon_type.csv_headers
        recon_builder.extract_recons(recon_type.set_name) do |recon|
          csv << recon
        end
      end
    end

  end
end
