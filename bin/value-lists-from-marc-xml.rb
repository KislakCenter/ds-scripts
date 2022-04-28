#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 CSV format.
#


require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'
require_relative '../lib/ds'

names = [
  %w{author_as_recorded	author_as_recorded_agr},
  %w{artist_as_recorded	artist_as_recorded_agr},
  %w{scribe_as_recorded	scribe_as_recorded_agr},
  %w{former_owner_as_recorded	former_owner_as_recorded_agr}
]

def pull_marc_names xml

end

options = {}
OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] --institution=INSTITUTION XML [XML ..]

Generate a DS 2.0 CSV from MARC XML.

EOF

  # We can't predictably extract the institution name from MARC records
  inst_help = "Short name of the institution to create this CSV for; REQUIRED"
  opts.on('-i INSTITUTION', '--institution=INSTITUTION', inst_help) do |inst|
    options[:institution] = inst
  end

  help_help = <<~EOF
Prints this help

You must provide a value for the '--institution' flag. Values are: #{DS::INSTITUTION_ALIASES.join ', '}

EOF
  opts.on("-h", "--help", help_help) do
    puts opts
    exit
  end
end.parse!

xmls = ARGV.dup

abort 'Please provide an input XML' if xmls.empty?
cannot_find = xmls.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?

abort "Please provide an --institution value" unless options[:institution]
inst_qid = DS.find_qid options[:institution]
abort "Not a known institution: #{options[:institution]}" unless inst_qid

names = [
  %w{author_as_recorded	author_as_recorded_agr},
  %w{artist_as_recorded	artist_as_recorded_agr},
  %w{scribe_as_recorded	scribe_as_recorded_agr},
  %w{former_owner_as_recorded	former_owner_as_recorded_agr}
]



timestamp = DS.timestamp

