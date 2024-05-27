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
      @validations   = {}
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
        recon_builder.each_recon(recon_type.set_name) do |recon|
          csv << recon
        end
      end
    end

    def validate(recon_type, recon, ndx: nil)
      errors = DS::Util::CsvValidator.validate_required_columns(recon, recon_type.csv_headers)
      # If required columns are missing, stop and raise an exception
      raise DSError.new errors.join("\n") unless errors.blank?
      errors = DS::Util::CsvValidator.validate_row(
        recon,
        required_columns: recon_type.csv_headers,
        balanced_columns: recon_type.balanced_columns,
        nested_columns:   recon_type.nested_columns,
        allow_blank:      false
      )
    end

    Validation = Struct.new :recon_type, :errors do
      def error_count
        errors.count
      end
    end
    def add_errors(recon_type, errors)
      @validations[recon_type.set_name] ||= Validation.new recon_type, errors

    end
  end
end
