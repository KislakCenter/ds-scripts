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
      @errors = {}
    end

    # Write all recon CSV files.
    #
    # @return [void]
    def write_all_csvs
      outfiles = []
      Recon::RECON_TYPES.each do |recon_type|
        outfile = File.join out_dir, "#{recon_type.set_name}.csv"
        write_csv recon_type, outfile
        outfiles << outfile
      end
      outfiles
    end

    # Write a CSV file for a specific recon type.
    #
    # @param recon_type [Recon::ReconType] the type of reconciliation data
    # @return [void]
    def write_csv recon_type, outfile
      CSV.open(outfile, 'w+', headers: true) do |csv|
        row_num = 0
        csv << recon_type.csv_headers
        recon_builder.each_recon(recon_type.set_name) do |recon|
          errors = Recon.validate_row(recon_type, recon, row_num: row_num+=1)
          add_errors recon_type, errors unless errors.blank?
          csv << recon
        end
      end
      if has_errors?(recon_type)
        raise DSError, "Error writing #{outfile}:\n#{errors_for_type(recon_type).join("\n")}"
      end
    end

    def add_errors(recon_type, errors)
      (@errors[recon_type.set_name] ||= []) << errors
    end

    def has_errors? recon_type
      errors_for_type(recon_type).present?
    end

    def errors_for_type recon_type
      @errors[recon_type.set_name]
    end


  end
end
