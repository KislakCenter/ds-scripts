require 'thor'
require_relative '../ds'

module DS
  class CLI < Thor
    include Recon
    DS.configure!

    class_option :'skip-recon-update', desc: "Skip CSV update from git; ignored by recon-update", aliases: '-G', type: :boolean, default: false
    class_option :'skip-validation', desc: "Skip validation of CSV values [same as SKIP_OUTPUT_VALIDATION=true]", aliases: '-V', type: :boolean, default: false

    desc "recon-update", "Update Recon CSVs from git"
    long_desc <<-LONGDESC
    Update Recon CSVs from #{Settings.recon.git_repo}.

    Note: this command ignores `--skip-recon-update` set SKIP_RECON_UPDATE
    environment variable to override.

    LONGDESC
    def recon_update
      if ENV['SKIP_RECON_UPDATE']
        STDERR.puts 'WARNING: SKIP_RECON_UPDATE set; skipping git pull'
        return
      end
      STDOUT.print "Updating Recon CSVs from #{Settings.recon.git_repo}..."
      Recon.update!
      STDOUT.puts "done."
    end

    protected
    def skip_git? options
      return true if options[:'skip-recon-update']
      return true if ENV['SKIP_RECON_UPDATE']
      false
    end

    ##
    # See if the user has signaled input is coming from STDIN
    #
    # @param files [Enumerable<String>] the file list from ARGV
    #     (by way of Thor)
    # @return [Boolean]
    def read_from_stdin? files
      files == ['-']
    end

    ##
    # Return the input to read from based on whether input is stdin.
    # If `read_from_stdin?` returns true, return +ARGF+; otherwise,
    # return +files+.
    #
    # @param files [Enumerable<String>] the file list from ARGV
    #     (by way of Thor)
    # @return [Enumerable] +files+ or +ARGF+
    def select_input files
      return files unless read_from_stdin? files
      ARGV.clear
      ARGF
    end

    def validate! rows
      return if options[:'skip-validation']
      return if ENV['SKIP_OUTPUT_VALIDATION']
      return if CSVUtil.validate rows

      raise StandardError, "Validation errors found in output"
    end
  end
end