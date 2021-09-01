#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 format.
#
# Input should be an MMS ID.
#
# The initial test set will use these IDs:
#
#   9947675343503681
#   9952666523503681
#   9959647633503681
#   9950569233503681
#   9976106713503681
#   9965025663503681


require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'

HEADINGS = %w{
ds_id
date_added
date_last_updated
holding_institution
holding_institution_id_number
link_to_holding_institution_record
production_place_as_recorded
production_place
production_date_as_recorded
production_date
century
dated
uniform_title_240
title_as_recorded_245
work_as_recorded
work
genre_as_recorded
genre
subject_as_recorded
subject
author_as_recorded
author
artist_as_recorded
artist
scribe_as_recorded
scribe
language_as_recorded
language
illuminated_initials
miniatures
former_owner_as_recorded
former_owner
former_id_number
material
physical_description
acknowledgements
binding
folios
dimensions
decoration
}

options = {}
OptionParser.new do |opts|

  opts.banner = "Usage: #{File.basename __FILE__} [options] XML"

  # r_help = %q{Directory containing source assets.path values [REQUIRED]}
  # opts.on "-r DIRECTORY", "--assets-root=DIRECTORY", r_help do |directory|
  #   validate_directory directory
  #   options[:assets_root] = directory
  # end
  #
  # n_help = %q{Dry run; do nothing; only report what would be done}
  # opts.on "-n", "--dry-run", n_help do |dry_run|
  #   options[:dry_run] = true
  # end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

in_xml = ARGV.shift

abort 'Please provide an input XML'           unless in_xml
abort "Can't find input XML: '#{in_xml}'"     unless File.exist? in_xml

xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
xml.remove_namespaces!

DEFAULT_VALUE_SEP = '|'
DEFAULT_WORD_SEP  = ' '

###
# Extract and combine MARC subfields for datafield
#
# @param [Nokogiri::XML::Node] :node the Nokogiri XML node for a single data
#     field
# @param [String] :datafield the marc field +@tag+, '099', '245', etc.
# @param [Array<String>] :subfields the MARC subfield +@code+ values, +a+, +h+,
#     etc.
# @param [String] :field_sep string to use for joins, [default: <tt>' '</tt>]
# @param [String] :record_sep string to use for joins, [default: <tt>'|'</tt>]
# @return [String]
def combine_subfields record:, datafield:, subfields: [], field_sep: ' ', record_sep: '|'

end

output_csv = %Q{#{in_xml.chomp '.xml'}.csv}

CSV.open output_csv, "w", headers: true do |row|
  row << HEADINGS

  holding_institution           = xml.xpath("//record/datafield[@tag=852]/subfield[@code='a']").text
  holding_institution_id_number = xml.xpath("//record/datafield[@tag=99]/subfield[@code='a']").text
  production_place_as_recorded  = xml.xpath("//record/datafield[@tag=260]/subfield[@code='a']").text
  production_date_as_recorded   = xml.xpath("//record/datafield[@tag=260]/subfield[@code='c']").text
  uniform_title_240             = xml.xpath("//record/datafield[@tag=240]/subfield[@code='a']").text
  title_as_recorded_245         = xml.xpath("//record/datafield[@tag=245]/subfield[@code='a']").text

  data = { 'holding_institution'           => holding_institution,
           'holding_institution_id_number' => holding_institution_id_number,
           'production_place_as_recorded'  => production_place_as_recorded,
           'production_date_as_recorded'   => production_date_as_recorded,
           'uniform_title_240'             => uniform_title_240,
           'title_as_recorded_245'         => title_as_recorded_245,
  }

  row << data
end

puts "Wrote: #{output_csv}"
