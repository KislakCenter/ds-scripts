require 'git'
require 'logger'

module DS
  module DSGit
    def self.update!
      repo_name = Settings.git.local_name
      url       = Settings.git.repo
      branch    = Settings.git.branch || 'main'
      logger    = DS.logger

      Dir.chdir DS.data_dir do
        unless File.exist? repo_name
          Git.clone url, repo_name, branch: branch, remote: 'origin', log: logger
        end
        g = Git.open repo_name, log: logger
        begin
          g.pull 'origin', branch
        rescue Git::GitExecuteError => e
          logger.warn { "Error executing git command" }
          logger.warn { e.message }
          STDERR.puts e.backtrace if ENV['DS_VERBOSE']
        end
      end
    end
  end
end