require_relative 'recon/names'
require_relative 'recon/places'
require_relative 'recon/subjects'
require_relative 'recon/named_subjects'
require_relative 'recon/genres'
require_relative 'recon/materials'
require_relative 'recon/languages'
require_relative 'constants'
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

  def self.lookup set_name, subset: nil, value:, column:
    recon_set = find_set set_name
    key = build_key value, subset
    return unless recon_set.include? key
    recon_set.dig key, column
  end

  def self.find_set set_name
    @@reconciliations ||= {}
    @@reconciliations[set_name] ||= load_set set_name
  end

  def self.recon_repo
    File.join DS.root, 'data', Settings.recon.git_local_name
  end

  def self.load_set set_name
    set_config = Settings.recon.sets.find { |s| s.name == set_name }
    raise "No configured set found for: '#{set_name}'" unless set_config

    csv_file = File.join recon_repo, set_config['repo_path']
    raise "Could not find CSV for set #{set_name}: #{csv_file}" unless File.exist? csv_file

    validate! set_config, csv_file

    data = {}
    CSV.foreach csv_file, headers: true do |row|
      struct        = OpenStruct.new row.to_h
      key_column    = set_config['key_column']
      subset_column = set_config['subset_column']
      value         = row[key_column]
      subset        = subset_column ? row[subset_column] : ''
      key           = build_key(value, subset)
      data[key]     = struct
    end
    add_alt_keys data
    data
  end

  def self.validate! set_config, csv_file

    headers = CSV.readlines(csv_file).first
    required_columns = []
    required_columns << set_config['key_column']
    required_columns << (set_config['structured_data_column'] || 'structured_value')
    required_columns << set_config['subset_column'] if set_config.include?('subset_column')
    required_columns << set_config['authorized_label_column'] if set_config.include?('authorized_label_column')
    required_columns << 'instance_of' if set_config['name'] == 'names'

    missing = required_columns.reject { |c| headers.include? c }
    return if missing.empty?

    raise "Could not find required columns (#{missing.join ', '}) in #{csv_file}"
  end

  def self.add_alt_keys data
    data.keys.each do |key|
      value, subset = key.split '$$'
      next unless value =~ DS::TRAILING_PUNCTUATION_RE
      alt_value = value.sub DS::TRAILING_PUNCTUATION_RE, ''
      alt_key = build_key alt_value, subset
      next if data.include? alt_key
      data[alt_key] = data[key]
    end
  end

  def self.build_key value, subset
    "#{value}$$#{subset}".downcase
  end
end