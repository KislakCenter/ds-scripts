#!/usr/bin/env ruby

require 'csv'
require 'optparse'

require_relative '../lib/ds/csv_util'

##
# Check all CSV values for trailing spaces
#

parser = OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} CSV [CSV...]

Check all values in CSV[s] for trailing spaces.

EOF
  help_help = 'Prints this help'
  opts.on "-h", "--help", help_help do
    puts opts
    exit
  end
end

parser.parse!

abort 'Please provide a CSV' if ARGV.empty?

ARGV.each do |csv|
  rows     = CSV.readlines(csv, headers: true).map &:to_h
  is_valid = DS::CSVUtil.validate rows

  flash = is_valid ? 'SUCCESS!' :'ERROR! '
  result = is_valid ? 'CSV is valid' : 'CSV is NOT valid'
  puts "#{flash} #{result} -- '#{csv}'"
end
