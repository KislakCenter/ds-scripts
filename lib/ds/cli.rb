require 'thor'
require_relative '../ds'

module DS
  class CLI < Thor
    include Recon
    DS.configure!

    class_option :'skip-recon-update', desc: "Skip CSV update from git; ignored by recon-update", aliases: '-G', type: :boolean, default: false

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
  end
end