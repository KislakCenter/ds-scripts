require_relative 'util'
require_relative 'recon/source_enumerator'
require_relative 'recon/ds_csv_enumerator'
require_relative 'recon/marc_xml_enumerator'
require_relative 'recon/tei_xml_enumerator'
require_relative 'recon/ds_mets_xml_enumerator'
require_relative 'recon/url_lookup'
require_relative 'recon/type/recon_type'
require_relative 'recon/type/genres'
require_relative 'recon/type/languages'
require_relative 'recon/type/materials'
require_relative 'recon/type/names'
require_relative 'recon/type/places'
require_relative 'recon/type/subjects'
require_relative 'recon/type/splits'
require_relative 'recon/type/named_subjects'
require_relative 'recon/type/all_subjects'
require_relative 'recon/type/titles'
require_relative 'recon/recon_builder'
require_relative 'recon/recon_manager'
require_relative 'constants'
require 'logger'
require 'csv'
require 'ostruct'

module Recon

  ERROR_UNBALANCED_SUBFIELDS = 'Row has unmatched subfields'
  ERROR_BLANK_SUBFIELDS = 'Row has blank subfields'
  ERROR_MISSING_REQUIRED_COLUMNS = "CSV is missing required column(s)"
  ERROR_CSV_FILE_NOT_FOUND = 'Recon CSV file cannot be found'


  RECON_SETS = %i{
    genres
    languages
    materials
    named-subjects
    names
    places
    subjects
    titles
  }
  # ReconConfig = Struct.new(:method_name, :klass, :set_name, keyword_init: true)
  RECON_TYPES = [
    Recon::Type::Genres,
    Recon::Type::Languages,
    Recon::Type::Materials,
    Recon::Type::NamedSubjects,
    Recon::Type::Names,
    Recon::Type::Places,
    Recon::Type::Subjects,
    Recon::Type::Titles
  ].freeze

  RECON_VALIDATION_SETS = RECON_TYPES.map(&:set_name).freeze

  def self.sort_and_dedupe array
    if array.first.is_a? Array
      array.sort { |a,b| a.first <=> b.first }.uniq &:join
    else
      array.sort.uniq
    end
  end

  ##
  # TODO: `column` is ambiguous; clarify
  def self.lookup set_name, subset: nil, value:, column:
    recon_set = find_set set_name
    key = build_key value, subset
    return recon_set.dig key, column if recon_set.include? key

    # try a key with a "cleaned" string
    key = build_key DS::Util.clean_string(value, terminator: ''), subset
    recon_set.dig(key, column) || ''
  end

  def self.find_set set_name
    @@reconciliations ||= {}
    @@reconciliations[set_name] ||= load_set set_name
  end

  def self.git_repo
    File.join Settings.recon.local_dir, Settings.recon.git_local_name
  end

  def self.find_set_config name
    config = Settings.recon.sets.find { |s| s.name == name }
    raise DSError, "Unknown set name: #{name.inspect}" unless config
    config
  end

  # Finds the reconciliation type configuration for the given set name.
  #
  # @param set_name [String] the name of the set
  # @return [Recon::Type::ReconType, nil] the configuration for the set name, or nil if not found
  def self.find_recon_type set_name
    RECON_TYPES.find { |config|
      config.set_name.to_sym == set_name.to_sym
    }
  end

  def self.csv_files set_name
    set_config = find_set_config set_name
    repo_paths = [set_config['repo_path']].flatten # ensure repo_path is an array
    repo_paths.map { |path| File.join Recon.git_repo, path }
  end

  def self.load_set set_name
    set_config = find_set_config set_name
    raise "No configured set found for: '#{set_name}'" unless set_config

    data = {}
    params = {
      key_column:    set_config['key_column'].to_sym,
      subset_column: (set_config['subset_column'] && set_config['subset_column'].to_sym),
      data:          data
    }

    # Path may be a single value or an array. Make sure it's an array.
    csv_files(set_name).each do |csv_file|
      params[:csv_file] = csv_file
      validate! set_name, params[:csv_file]
      read_csv **params
    end

    add_alt_keys data
    data
  end

  def self.read_csv csv_file:, key_column:, subset_column:, data:
    CSV.foreach csv_file, headers: true do |row|
      row = row.to_h.symbolize_keys
      next if %i{authorized_label structured_value}.all? { |k| row[k].blank? }
      struct    = OpenStruct.new row.to_h
      value     = row[key_column]
      subset    = subset_column ? row[subset_column] : ''
      key       = build_key value, subset
      data[key] = struct
    end
    data
  end


  def self.validate set_name, csv_file
    return unless RECON_VALIDATION_SETS.include? set_name
    return "#{ERROR_CSV_FILE_NOT_FOUND}: '#{csv_file}'" unless File.exist? csv_file

    recon_type = Recon.find_recon_type set_name
    row_num    = 0
    CSV.readlines(csv_file, headers: true).map(&:to_h).filter_map { |row|
      row.symbolize_keys!
      error = validate_row recon_type, row, row_num+=1
      error if error.present?
    }
  end

  def self.validate! set_name, csv_file
    error = validate set_name, csv_file
    return unless error.present?

    raise DSError, "Error validating #{set_name} recon CSV #{csv_file}:\n#{error}"
  end

  def self.validate_row recon_type, row, row_num
    errors = DS::Util::CsvValidator.validate_required_columns(row, required_columns: recon_type.csv_headers, row_num: row_num)
    raise DSError.new errors.join("\n") unless errors.blank?
    DS::Util::CsvValidator.validate_balanced_columns(
      row, balanced_columns: recon_type.balanced_columns, row_num: row_num
    )
  end

  def self.add_alt_keys data
    data.keys.each do |key|
      value, subset = key.split '$$'
      # create a cleaned version of the value without final punctuation
      alt_value = DS::Util.clean_string value, terminator: ''
      alt_key = build_key alt_value, subset
      next if data.include? alt_key
      data[alt_key] = data[key]
    end
  end

  def self.build_key value, subset
    DS::Util.unicode_normalize "#{value}$$#{subset}".downcase
  end
end
