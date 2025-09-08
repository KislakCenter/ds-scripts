require 'config'
require 'active_support/all'

require_relative 'ds/ds_error'
require_relative 'ds/util'
require_relative 'ds/recon/recon_data'
require_relative 'ds/constants'
require_relative 'ds/source'
require_relative 'ds/extractor'
require_relative 'ds/extractor/ds_mets_xml_extractor'
require_relative 'ds/extractor/tei_xml_extractor'
require_relative 'ds/extractor/marc_xml_extractor'
require_relative 'ds/csv_util'
require_relative 'ds/extractor/ds_csv_extractor'
require_relative 'ds/recon'
require_relative 'ds/institutions'
require_relative 'ds/mapper'
require_relative 'ds/manifest'
require_relative 'ds/converter'
require_relative 'ds/version'

module DS
  include DS::Constants

  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.env
    @@env ||= 'production'
  end

  def self.env= environment
    @@env = environment
  end

  def self.normalize_key key
    return '' if key.blank?
    key.to_s.downcase.strip.gsub %r{\W+}, ''
  end

  def self.data_dir
    File.join root, 'data'
  end

  def self.configure!
    config_dir = File.join root, 'config'
    # Set Settings, so you can do things like Settings.recon.key ...
    Config.load_and_set_settings(Config.setting_files config_dir, DS.env)
  end

  module ClassMethods
    def mark_long s
      return s if s.to_s.size <= DS::MAX_WIKIBASE_FIELD_LENGTH

      splits = Recon::Type::Splits._lookup_single s, from_column: 'authorized_label'
      return "SPLIT: #{s}" if splits.blank?
      splits
    end

    ##
    # Given a pipe separated list of single years or ranges of years, return
    # a pipe- and semicolon-separated list of century integers. Year ranges
    # are separated by the +^+ character, so that +-+ can unambiguously be
    # used for BCE years as negative integers (<tt>1099-1000 BCE</tt> =>
    # <tt>-1099^-1000</tt>)
    #
    # For example,
    #
    #     DS.transform_dates_to_centuries('1400')           # => '15'
    #     DS.transform_dates_to_centuries('1400^1499')      # => '15'
    #     DS.transform_dates_to_centuries('1325|1400^1499') # => '14|15'
    #     DS.transform_dates_to_centuries('890^1020')       # => '9;10;11'
    #     DS.transform_dates_to_centuries('-800^-701')      # => '-8'
    #
    # @param [String] dates a pipe separated list of single dates or date
    #    ranges: '1832', '1350^1520'
    # @return [String] a pipe-separated century integers
    def transform_dates_to_centuries dates
      return if dates.blank?
      dates.to_s.split('|').flat_map { |date_range|
        next [] if date_range.strip.empty? # don't process empty values
        # Adjust ranges to return sensible centuries for ranges like
        # '1400-1499' or '1401-1500'
        date_range = adjust_for_century date_range
        # turn the date/date range into a [min,max] array of century integers:
        #     1350-1550 => [14,16]
        #     1350      => [14]
        centuries = date_range.split('^').map { |i| calculate_century i }.sort
        # get an array for the range of centuries:
        #       [14,16] => 14, 15, 16
        # join them; throw away zero if range spans BCE/CE
        (centuries.first..centuries.last).to_a.reject(&:zero?).join ';' # join list of centuries by semicolons
      }.join '|'
    end

    ##
    # Take a formatted string of century integers and return the string AAT
    # century URIs, retaining the divisions.
    #
    # @param [String] centuries_string
    # @return [String]
    def transform_centuries_to_aat centuries_string, rec_sep: '|', sub_sep: ';'
      return if centuries_string.to_s.strip.empty?

      centuries_string.split(rec_sep).map { |century_range|
        century_range.split(sub_sep).map { |century_int|
          lookup_century century_int
        }.join sub_sep
      }.join rec_sep
    end

    ##
    # Adjust date ranges so that intended results are returned for century
    # values. Thus:
    #
    #      1400 to  1499     => 15th C. CE
    #      1401 to  1500     => 15th C. CE
    #
    # And, thus:
    #
    #     -1499 to -1400     => 15th C. BCE
    #     -1500 to -1401     => 15th C. BCE
    #
    # This method adjusts the end year for CE dates and the start
    # year for BCE dates as needed:
    #
    #     DS.adjust_for_century '1325'          # => '1325';        no change needed
    #     DS.adjust_for_century '1400^1499'     # => '1400^1499';   no change needed
    #     DS.adjust_for_century '1401^1500'     # => '1401^1499'
    #     DS.adjust_for_century '-1500^-1401'   # => '-1500^-1401'; no change needed
    #     DS.adjust_for_century '-1499^-1400'   # => '-1499^-1401'
    #
    # @param [String] range a single year or +^+-separated date range
    # @return [String] the range, adjusted if needed
    def adjust_for_century range
      # return a single date
      return range if range =~ %r{^-?\d+$}

      start_year, end_year = range.split('^')
      start_int, end_int   = start_year.to_i, end_year.to_i

      # end dates divisible by 100 need to be reduced by one:
      #   1500 => 1499; -1500 => -1501
      end_int              -= 1 if end_int % 100 == 0
      [start_int, end_int].uniq.join '^'
    end

    ##
    # Given a year, return to the corresponding century as an integer following
    # this pattern:
    #
    # - the 16th C. CE is years 1500 to 1599
    # - the 1st C. CE is years 0 to 99
    # - the 16th C. BCE is years -1599 to -1501
    #
    # Thus:
    #
    #     DS.calculate_century '1501'   # =>  16
    #     DS.calculate_century '1600'   # =>  17
    #     DS.calculate_century '-1600'  # => -16
    #     DS.calculate_century '-1501'  # => -16
    #     DS.calculate_century '1'      # =>   1
    #     DS.calculate_century '0'      # =>   1
    #
    # @param [Integer] year an integer year value
    # @return [Integer] an integer representation of the century
    def calculate_century year
      # remove leading 0s; 4-digit numbers starting with 0 are octal
      year_int = Integer year
      # year <=> 0 returns 1 if year > 0; -1 if year < 0; 0 if year == 0
      # 0 is a special year; its sign is 1 and its absolute value is 1
      sign    = year_int == 0 ? 1 : (year_int <=> 0)
      abs_val = year_int == 0 ? 1 : year_int.abs
      offset  = sign < 0 ? 1 : 0

      # if year is 1501, sign == 1 and abs_val == 1501
      #     => 1 * ((1501 - 1)/100 +1) => 1 * (1500/100 + 1) => 1 * (15 + 1) = 16
      # if year is 1500, sign == 1 and abs_val == 1500
      #     => 1 * ((1500 - 1)/100 +1) => 1 * (1499/100 + 1) => 1 * (14 + 1) = 15
      sign * ((abs_val - offset) / 100 + 1)
    end

    def timestamp
      DateTime.now.iso8601.to_s
    end

    @@centuries = nil
    ##
    # Look up the URI for +century+, where century is an integer like +1+, +12+,
    # +-3+, etc.
    # Values are read in from the file `data/getty-aat-centuries.csv` and
    # converted to a hash of Getty AAT century URIs. Keys are century integers,
    # like '1', '2', '3', '-1', '-2', '-3', etc. and values are AAT URIs.
    #
    # @param [Integer] century an integer like +1+, +12+, +-3+, etc.
    # @return [String] the AAT URI for the century
    def lookup_century century
      if @@centuries.nil?
        path = File.expand_path '../ds/data/getty-aat-centuries.csv', __FILE__

        # aat_id,label,number
        # http://vocab.getty.edu/aat/300404465,fifteenth century (dates CE),15
        # http://vocab.getty.edu/aat/300404493,first century (dates CE),1
        @@centuries = CSV.read(path).inject({}) do |h, row|
          if row.first == 'aat_id'
            h
          else
            h.update({ row.last => row.first })
          end
        end.freeze
      end
      @@centuries[century.to_s]
    end

    @@logger = nil
    @@loggers = {}
    def logger
      return @@logger if @@logger
      @@logger = DS.logger_for self.class.name
    end


    def logger_for(classname)
      @@loggers[classname] ||= configure_logger_for(classname)
    end

    def configure_logger_for(classname)
      logger = Logger.new(STDOUT)
      logger.progname = classname
      logger.level = Settings.ds.log_level || :warn
      logger
    end
  end

  self.extend ClassMethods
end
