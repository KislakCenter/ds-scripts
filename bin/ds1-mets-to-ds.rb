#!/usr/bin/env ruby

######
# Script to convert legacy Digital Scriptorium METS/MODS to DS 2.0 CSV format.
#

require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'
require_relative '../lib/ds'


options = {}
OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] XML [XML ..]

Generate a DS 2.0 CSV from legacy DS METS/MODS XML.

EOF

  opts.on('-o FILE', '--output-csv=FILE', "Name of the output CSV file [default: output.csv]") do |output|
    options[:output_csv] = output
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

xmls = ARGV.dup

abort 'Please provide an input XML' if xmls.empty?
cannot_find = xmls.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?

DEFAULT_FIELD_SEP = '|'
DEFAULT_WORD_SEP  = ' '

output_csv = options[:output_csv] || 'output.csv'
timestamp = DS.timestamp

seen = []
CSV.open output_csv, "w", headers: true do |row|
  row << DS::HEADINGS

  xmls.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }

    source_type                        = 'digital-scriptorium'
    holding_institution_as_recorded    = DS::DS10.extract_institution_name xml
    holding_institution                = DS::INSTITUTION_NAMES_TO_QID.fetch holding_institution_as_recorded, ''
    holding_institution_id_number      = DS::DS10.extract_institution_id xml
    link_to_holding_institution_record = DS::DS10.extract_link_to_inst_record xml
    production_place_as_recorded       = DS::DS10.extract_production_place xml
    production_place                   = ''
    production_date_as_recorded        = DS::DS10.extract_date_as_recorded xml
    production_date                    = DS::DS10.transform_production_date xml
    century                            = DS.transform_dates_to_centuries production_date
    century_aat                        = DS.transform_centuries_to_aat century
    dated                              = DS::DS10.dated_by_scribe? xml
    uniform_title_as_recorded          = ''
    uniform_title_agr                  = ''
    title_as_recorded_245              = DS::DS10.extract_title xml
    title_as_recorded_245_agr          = ''
    genre_as_recorded                  = ''
    subject_as_recorded                = ''
    author_as_recorded                 = DS::DS10.extract_text_name xml, 'author'
    author_as_recorded_agr             = ''
    artist_as_recorded                 = DS::DS10.extract_part_name xml, 'artist'
    artist_as_recorded_agr             = ''
    scribe_as_recorded                 = DS::DS10.extract_part_name xml, 'scribe'
    scribe_as_recorded_agr             = ''
    language_as_recorded               = DS::DS10.extract_language xml
    language                           = ''
    former_owner_as_recorded           = DS::DS10.extract_ownership xml
    former_owner_as_recorded_agr       = ''
    material                           = ''
    material_placeholder               = DS::DS10.extract_support xml
    physical_description               = DS::DS10.extract_physical_description xml
    acknowledgements                   = DS::DS10.extract_acknowledgements xml
    data_processed_at                  = timestamp
    data_source_modified               = DS::DS10.source_modified
    source_file                        = in_xml

    data = { source_type:                        source_type,
             holding_institution:                holding_institution,
             holding_institution_as_recorded:    holding_institution_as_recorded,
             holding_institution_id_number:      holding_institution_id_number,
             link_to_holding_institution_record: link_to_holding_institution_record,
             production_date:                    production_date,
             production_place_as_recorded:       production_place_as_recorded,
             production_place:                   production_place,
             century:                            century,
             century_aat:                        century_aat,
             dated:                              dated,
             production_date_as_recorded:        production_date_as_recorded,
             uniform_title_as_recorded:          uniform_title_as_recorded,
             uniform_title_agr:                  uniform_title_agr,
             title_as_recorded_245:              title_as_recorded_245,
             title_as_recorded_245_agr:          title_as_recorded_245_agr,
             genre_as_recorded:                  genre_as_recorded,
             subject_as_recorded:                subject_as_recorded,
             author_as_recorded:                 author_as_recorded,
             author_as_recorded_agr:             author_as_recorded_agr,
             artist_as_recorded:                 artist_as_recorded,
             artist_as_recorded_agr:             artist_as_recorded_agr,
             scribe_as_recorded:                 scribe_as_recorded,
             scribe_as_recorded_agr:             scribe_as_recorded_agr,
             language_as_recorded:               language_as_recorded,
             language:                           language,
             former_owner_as_recorded:           former_owner_as_recorded,
             former_owner_as_recorded_agr:       former_owner_as_recorded_agr,
             material_placeholder:               material_placeholder,
             material:                           material,
             physical_description:               physical_description,
             acknowledgements:                   acknowledgements,
             data_processed_at:                  data_processed_at,
             data_source_modified:               data_source_modified,
             source_file:                        source_file,
    }

    row << data
  end
end

puts "Wrote: #{output_csv}"