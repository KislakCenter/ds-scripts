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

# The DS Recon module contains classes and methods for working with DS
# recon data dictionaries.
#
# The classes in this module manage and support all the following:
#
# - The loading recon data dictionary CSV files for recon lookups
# - The generation of recon CSV files from import sources
# - The addition of recon data to import CSVs
#
# The key modules and classes in the Recon module are:
#
# - {Recon} -- validation and loading of recon data dictionary CSVs; data dictionary lookups; retrieval and updates of the DS data git repository, which includes the data dictionary CSVs
# - {Recon::Type} -- recon type configurations used for lookups, extractions, and column mappings
# - {Recon::ReconManager} -- the main interface for the Recon module; used to build and write recon CSVs
# - {Recon::ReconBuilder} -- used by the Recon::Manager to build recon values hashes by extracting DS::Extractor::BaseTerm instances from source records and performing lookups
# - {Recon::SourceEnumerator} instances -- used by Recon::ReconBuilder to iterate over source records
#
# @example
#     require 'ds'
#     # write the places.csv file for a set of MARC XML files
#     files = Dir['source/files/*.xml']
#     recon_manager = Recon::ReconManager.new(
#       source_type: 'marc-xml',
#       out_dir: 'path/to/dir',
#       files: files
#     )
#     recon_type = Recon.find_recon_type :places
#     recon_manager.write_csv recon_type # => 'path/to/dir/places.csv'
#
#
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


  RECON_TYPES_MAP = {
    :genres => Recon::Type::Genres,
    :languages => Recon::Type::Languages,
    :materials => Recon::Type::Materials,
    :'all-subjects' => Recon::Type::Subjects,
    :'named-subjects' => Recon::Type::NamedSubjects,
    :names => Recon::Type::Names,
    :places => Recon::Type::Places,
    :subjects => Recon::Type::Subjects,
    :titles => Recon::Type::Titles,
    :splits => Recon::Type::Splits
  }.freeze

  RECON_TYPES = RECON_TYPES_MAP.values.freeze

  RECON_VALIDATION_SETS = RECON_TYPES.map(&:set_name).freeze

  def self.sort_and_dedupe array
    if array.first.is_a? Array
      array.sort { |a,b| a.first <=> b.first }.uniq &:join
    else
      array.sort.uniq
    end
  end



  # For the recon data dictionary with +set_name+, find the value in the +column+ with the
  # key <tt>value + subset</tt>.
  #
  # @param [String] set_name the name of the set to look up
  # @param [String, nil] subset the subset within the set, default is nil
  # @param [String] value the value to look up
  # @param [Symbol] column the column value to retrieve
  # @return [Object, nil] the value found in the specified column, or nil if not found
  def self.lookup_single set_name, subset: nil, value:, column:
    recon_set = find_set set_name
    key = build_key [value, subset]
    return recon_set.dig key, column if recon_set.include? key

    # try a key with a "cleaned" string
    alt_key = build_alt_key key
    recon_set.dig(alt_key, column)
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
    return RECON_TYPES_MAP[set_name.to_sym] if RECON_TYPES_MAP.key? set_name.to_sym

    raise "Unknown recon set_name: #{set_name.inspect}"
  end

  def self.csv_files set_name
    set_config = find_set_config set_name
    repo_paths = [set_config['repo_path']].flatten # ensure repo_path is an array
    repo_paths.map { |path| File.join Recon.git_repo, path }
  end

  def self.load_set set_name
    set_config = find_set_config set_name
    recon_type = find_recon_type set_name
    raise "No configured set found for: '#{set_name}'" unless set_config

    data = {}
    params = {
      recon_type:    recon_type,
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

  def self.read_csv csv_file:, recon_type:, data:
    CSV.foreach csv_file, headers: true do |row|
      row = row.to_h.symbolize_keys
      next if recon_type.lookup_values(row).blank?
      struct    = OpenStruct.new row.to_h
      key       = build_key recon_type.key_values row
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
    errors = DS::Util::CsvValidator.validate_required_columns(row, required_columns: recon_type.recon_csv_headers, row_num: row_num)
    raise DSError.new errors.join("\n") unless errors.blank?
    DS::Util::CsvValidator.validate_balanced_columns(
      row, balanced_columns: recon_type.balanced_columns, row_num: row_num
    )
  end

  def self.add_alt_keys data
    data.keys.each do |key|
      alt_key = build_alt_key key
      next if data.include? alt_key
      data[alt_key] = data[key]
    end
  end

  # Builds an alt key from key, splitting it into an array of values,
  # invoking DS::Util::clean_string on each value and rejoining the
  # cleaned values separated by '$$'.
  #
  # @param key [String] the key to be included in the alt key
  # @return [String] the built alt key
  def self.build_alt_key key
    key.split('$$').map { |v|
      DS::Util.clean_string v, terminator: ''
    }.join '$$'
  end

  # Builds a key by concatenating the normalized Unicode representation of +values+,
  # separated by '$$', and converts it to lowercase.
  #
  # @param values [Array<String>] the values to be included in the key
  # @param subset [String] the subset to be included in the key
  # @return [String] the built key
  def self.build_key values
    DS::Util.unicode_normalize values.select(&:present?).join('$$').downcase
  end
end
