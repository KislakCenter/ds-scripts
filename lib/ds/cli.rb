require 'thor'
require 'colorize'
require_relative '../ds'

module DS
  class CLI < Thor
    include Recon
    include ActiveSupport::NumberHelper

    DS.env = (ENV['DS_ENV'].present? ? ENV['DS_ENV'] : 'production')
    DS.configure!

    class_option :'skip-recon-update', desc: "Skip CSV update from git [ignored by recon-update, validate]", aliases: '-G', type: :boolean, default: false
    class_option :'skip-validation', desc: "Skip validation of CSV values [same as SKIP_OUTPUT_VALIDATION=true, ignored by recon-update, validate]", aliases: '-V', type: :boolean, default: false
    class_option :verbose, desc: "Be chatty; print stacktraces; overrides --quiet", aliases: '-v', type: :boolean, default: false
    class_option :quiet, desc: "Don't print messages", aliases: '-q', type: :boolean, default: false


    desc "recon-update", "Update Recon CSVs from git"
    long_desc <<-LONGDESC
    Update Recon CSVs from #{Settings.recon.git_repo}.

    NOTE: This command ignores all options, including `--skip-recon-update`; set
          the SKIP_RECON_UPDATE environment variable to override.

    LONGDESC
    def recon_update(*args)
      # allow any args so this command can be invoked by any other
      if skip_git? options
        print_message(options, verbose_only: true) { <<~EOF.squish }
          WARNING: SKIP_RECON_UPDATE or 
          --skip-recon-update set; skipping git pull
        EOF
        return
      end
      STDOUT.print "Updating Recon CSVs from #{Settings.recon.git_repo}..."
      Recon::ReconData.update!
      STDOUT.puts "done."
    end

    ##
    # Needed to return a non-zero exit code on failure. See:
    #
    # https://github.com/rails/thor/wiki/Making-An-Executable
    def self.exit_on_failure?
      true
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
    # @param [String] msg the message to print
    # @param [Hash] options the command options; the following are used here:
    # @option options [Boolean] :verbose whether to print all messages
    # @option option [Boolean] :quiet suppress all messages (except errors); overrides +:verbose+
    # @param [Boolean] verbose_only print message only if +:verbose+ is true
    def print_message options, verbose_only: false, &msg
      return if options[:quiet]
      # if +verbose_only+ is true, return unless +options[:verbose]+ is true
      return if verbose_only && ! options[:verbose]

      puts yield
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
