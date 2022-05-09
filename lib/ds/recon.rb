require_relative 'recon/names'
require_relative 'recon/places'
require_relative 'recon/subjects'
require_relative 'recon/genres'
require 'git'
require 'logger'
require 'csv'
require 'ostruct'

module Recon
  def self.update!
    data_dir = File.join DS.root, 'data'
    repo_name = Settings.recon.git_local_name
    url = Settings.recon.git_repo
    branch = Settings.recon.git_branch || 'main'
    git_dir = File.join data_dir, repo_name
    logger = Logger.new STDOUT
    logger.level = Logger::WARN
    Dir.chdir data_dir do
      unless File.exist? repo_name
        Git.clone url, repo_name, branch: branch, remote: 'origin', log: logger
      end
      g = Git.open repo_name, log: logger
      g.pull 'origin', branch
    end
  end

  def self.sort_and_dedupe array
    if array.first.is_a? Array
      array.sort { |a,b| a.first <=> b.first }.uniq &:join
    else
      array.sort.uniq
    end
  end

  def self.look_up set_name, subset: nil, key:, column:
    recon_set = find_set set_name, subset: subset
    return unless recon_set.include? key
    recon_set.dig key, column
  end

  @@reconciliations = {}
  def self.find_set set_name, subset: nil
    load_set set_name unless @@reconciliations.include? set_name
    return @@reconciliations[set_name] unless subset

    set_config = Settings.recon.sets.find { |s| s.name == set_name }
    subset_column = set_config.subset_column
    @@reconciliations[set_name].select { |value,row| row[subset_column] = subset }
  end

  def self.recon_repo
    File.join DS.root, 'data', Settings.recon.git_local_name
  end

  def self.load_set set_name
    set_config = Settings.recon.sets.find { |s| s.name == set_name }
    raise "No configured set found for: '#{set_name}'" unless set_config

    csv_file = File.join recon_repo, set_config['repo_path']
    raise "Could not find CSV for set #{set_name}: #{csv_file}" unless File.exist? csv_file

    key_column = set_config['key_column']
    data = {}
    CSV.foreach csv_file, headers: true do |row|
      data[row[key_column]] = OpenStruct.new row.to_h
    end
    @@reconciliations[set_name] = data
  end
end