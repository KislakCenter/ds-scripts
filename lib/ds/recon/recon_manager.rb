# frozen_string_literal: true

module Recon
  class ReconManager

    attr_reader :out_dir
    attr_reader :source_type
    attr_reader :files

    # Initialize the ReconManager.
    #
    # @param source_type [Symbol] a valid DS data source type; e.g., DS::Constants::MARC_XML
    # @param out_dir [String] the output directory path
    # @param files [Array<String>] an array of source file paths; e.g., +marc1.xml+, +marc2.xml+, etc.
    # @return [void]
    def initialize source_type:, out_dir:, files:
      @source_type   = source_type
      @out_dir       = out_dir
      @files         = files
      @errors        = {}
    end

    # Write all recon CSV files.
    #
    # @return [Array<String>] the list of output files
    def write_all_csvs
      outfiles = []
      Recon::RECON_TYPES.each do |recon_type|
        # outfile = File.join out_dir, "#{recon_type.set_name}.csv"
        outfiles << write_csv(recon_type)
      end
      outfiles
    end

    # Write a CSV file for a specific recon type.
    #
    # @param recon_type [Recon::ReconType] the type of reconciliation data
    # @return [String] the path to the output CSV file
    def write_csv recon_type
      outfile = File.join out_dir, "#{recon_type.set_name}.csv"
      CSV.open(outfile, 'w+', headers: true) do |csv|
        row_num = 0
        csv << recon_type.csv_headers
        recon_builder.each_recon(recon_type.set_name) do |recon|
          errors = Recon.validate_row(recon_type, recon, row_num: row_num += 1)
          add_errors recon_type, errors unless errors.blank?
          csv << recon
        end
      end
      if has_errors?(recon_type)
        raise DSError, "Error writing #{outfile}:\n#{errors_for_type(recon_type).join("\n")}"
      end
      outfile
    end

    # Initializes and returns a new instance of the Recon::ReconBuilder class with the specified output directory, source type, and files.
    #
    # @return [Recon::ReconBuilder] A new instance of the Recon::ReconBuilder class.
    def recon_builder
      @recon_builder ||= Recon::ReconBuilder.new(
        out_dir: out_dir, source_type: source_type, files: files
      )
    end

    # Adds errors to the specified recon type.
    #
    # @param recon_type [ReconType] the recon type to add errors to
    # @param messages [Array<String>] the errors to add
    # @return [void]
    def add_errors recon_type, messages
      @errors[recon_type.set_name] ||= []
      @errors[recon_type.set_name] += messages
      nil
    end

    # Returns true if errors exist for the specified recon type.
    #
    # @param recon_type [ReconType] the recon type
    # @return [Boolean] true if errors exist
    def has_errors? recon_type
      errors_for_type(recon_type).present?
    end

    # Returns the list of errors for the specified recon type.
    #
    # @param recon_type [ReconType] the recon type
    # @return [Array<String>] the list of errors
    def errors_for_type recon_type
      @errors[recon_type.set_name]
    end

  end
end
