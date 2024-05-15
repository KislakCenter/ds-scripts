require_relative 'util'
require_relative 'recon/source_enumerator'
require_relative 'recon/ds_csv_enumerator'
require_relative 'recon/marc_xml_enumerator'
require_relative 'recon/tei_xml_enumerator'
require_relative 'recon/ds_mets_xml_enumerator'
require_relative 'recon/url_lookup'
require_relative 'recon/genres'
require_relative 'recon/languages'
require_relative 'recon/materials'
require_relative 'recon/names'
require_relative 'recon/places'
require_relative 'recon/subjects'
require_relative 'recon/splits'
require_relative 'recon/named_subjects'
require_relative 'recon/all_subjects'
require_relative 'recon/titles'
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
  ReconConfig = Struct.new(:method_name, :klass, :set_name, keyword_init: true)
  RECON_TYPES = [
    ReconConfig.new(
      method_name: %i[extract_genres],
      klass: Recon::Genres,
      set_name: Recon::Genres.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_languages],
      klass: Recon::Languages,
      set_name: Recon::Languages.set_name
    ),
    ReconConfig.new(
      method_name:   :extract_materials,
      klass: Recon::Materials,
      set_name: Recon::Materials.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_named_subjects],
      klass: Recon::NamedSubjects,
      set_name: Recon::NamedSubjects.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_authors extract_artists extract_scribes extract_former_owners],
      klass: Recon::Names,
      set_name: Recon::Names.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_places],
      klass: Recon::Places,
      set_name: Recon::Places.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_subjects],
      klass: Recon::Subjects,
      set_name: Recon::Subjects.set_name
    ),
    ReconConfig.new(
      method_name: %i[extract_titles],
      klass: Recon::Titles,
      set_name: Recon::Titles.set_name
    ),
  ]

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

  def self.find_recon_config set_name
    RECON_TYPES.find { |config| config.set_name == set_name }
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
      key_column:    set_config['key_column'],
      subset_column: set_config['subset_column'],
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
      next if %w{authorized_label structured_value}.all? { |k| row[k].blank? }
      struct    = OpenStruct.new row.to_h
      value     = row[key_column]
      subset    = subset_column ? row[subset_column] : ''
      key       = build_key value, subset
      data[key] = struct
    end
    data
  end

  ##
  # Return an error if each value in +row_values+ has the same number of subfields
  # **and** none of the subfields are blank; otherwise, return +nil+.
  #
  # If +allow_blank+ is +true+, ignore blanks, only check for balanced
  # subfields.
  #
  # Note: It is always allowed for every value to be blank (empty string).
  #
  # So:
  #
  #   [ 'a|b|c', '1|2|3' ]   # => valid, return nil
  #   [ '', '' ]             # => valid, return nil
  #   [ 'a|b|c', '1|2' ]     # => not valid, return ERROR_UNBALANCED_SUBFIELDS
  #   [ 'a||c', '1|2|3' ]    # => not valid, return ERROR_BLANK_SUBFIELDS
  #   [ 'a||c', '1|2|3' ]    # => valid, if allow_blank == true, return nil
  #
  # @param [Array<String>] row_values an array of strings from one or more columns
  # @param [String] separators a list of allowed subfield separators; e.g., ';', '|', ';|'
  # @param [Boolean] allow_blank whether any of the subfields may be blank
  # @return [String] the row error or +nil+ if there are no errors
  def self.validate_row_splits row_values: [], separators: '|;', allow_blank: false
    # return true if all the values are empty
    return if row_values.all? { |val| val.to_s.strip.empty? }
    # Input array is an array of two or more strings that must split into
    # equal numbers of subfields.
    #
    #   ['a|bc', '1|2|3'] => [['a', 'b', 'c'],
    #                         ['1', '2', '3']]
    #   ['a|b|c', '1|2']  => [['a', 'b', 'c'],
    #                         ['1' '2']]
    #
    # Count the subfields and make sure there's an equal number in each field
    #
    #    ['a|bc', '1|2|3'] => # 3 subfields each; => valid
    #    ['a|b|c', '1|2']  => # 2 and 3 subfields; => not valid
    subfield_values = row_values.map { |v| v.split %r{[#{Regexp.escape separators}]} }
    # there should be only one subfield length:
    subfield_lengths = subfield_values.map { |vals| vals.size }.uniq
    return ERROR_UNBALANCED_SUBFIELDS if subfield_lengths.size > 1

    # return true if we don't have check for blanks
    return nil if allow_blank

    # return an error if any of the subfields are blank
    return ERROR_BLANK_SUBFIELDS if subfield_values.flatten.any? { |sub| sub.to_s.strip.empty? }
  end

  ##
  # Check CSV for presence of required columns by heading name. Return +nil+ if
  # all required columns present. Otherwise, return an error message.
  #
  #    Recon.validate_columns 'names', 'path/to/names.csv'
  #      # => "CSV is missing required column(s) (path/to/names.csv): instance_of"
  #
  # @param [String] set_name the name of the recon set; 'names', 'genres', etc.
  # @param [String] csv_file the path to the CSV file
  # @return [Array<String>,NilClass] list of any missing columns; +nil+ otherwise
  def self.validate_columns set_name, csv_file
    set_config = Recon.find_set_config set_name
    required_columns = []
    required_columns << set_config['key_column']
    required_columns << (set_config['structured_data_column'] || 'structured_value')
    required_columns << set_config['subset_column'] if set_config.include?('subset_column')
    required_columns << set_config['authorized_label_column'] if set_config.include?('authorized_label_column')
    required_columns << 'instance_of' if set_config['name'] == 'names'

    headers = CSV.readlines(csv_file).first
    missing = required_columns.reject { |c| headers.include? c }

    return if missing.empty?
    "#{ERROR_MISSING_REQUIRED_COLUMNS}: (#{csv_file}) #{missing.join ', '}"
  end

  def self.validate_csv_splits set_name, csv_file
    set_config = Recon.find_set_config set_name
    return unless set_config['balanced_columns']

    balanced_columns = set_config['balanced_columns']
    errors = []
    csv = CSV.open csv_file, headers: true
    csv.each do |row|
      row_values = balanced_columns.map { |col| row[col] }
      error =  validate_row_splits row_values: row_values, separators: ';|'
      next unless error
      errors << "#{error}: #{csv_file}, line #{csv.lineno}: #{row}"
    end
    csv.close

    return if errors.empty?
    errors
  end

  def self.validate set_name, csv_file
    return "#{ERROR_CSV_FILE_NOT_FOUND}: '#{csv_file}'" unless File.exist? csv_file

    column_error = validate_columns set_name, csv_file
    return column_error if column_error

    splits_errors = validate_csv_splits set_name, csv_file
    return splits_errors.join "\n" if splits_errors
  end

  def self.validate! set_name, csv_file
    error = validate set_name, csv_file
    return unless error

    raise DSError, "Error validating #{set_name} recon CSV #{csv_file}:\n#{error}"
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
