#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 CSV format.
#


require 'marc'
require 'csv'
require 'optionparser'
require_relative '../lib/ds'

options = {}
OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] XML [XML ..]

Generate a DS 2.0 CSV from MARC XML.

EOF

  opts.on('-o FILE', '--output-csv=FILE', "Name of the output CSV file [default: output.csv]") do |output|
    options[:output_csv] = output
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

marc_mrc = ARGV.dup

abort 'Please provide an input MRC' if marc_mrc.empty?
cannot_find = marc_mrc.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?

DEFAULT_FIELD_SEP = '|'
DEFAULT_WORD_SEP  = ' '

output_csv = options[:output_csv] || 'output.csv'

CSV.open output_csv, "w", headers: true do |row|
  row << DS::HEADINGS

  marc_mrc.each do |mrc|
    reader = MARC::Reader.new(mrc, :external_encoding => "MARC-8")

    reader.each_with_index do |record,ndx|
      marc_out =  sprintf 'cornell-marc-%03d.xml', ndx
      File.open(marc_out, 'w+') { |f| f.puts record.to_xml }
      puts "Wrote #{marc_out}"
      source_type                        = 'marc-mrc'
      holding_institution                = ''
      holding_institution_as_recorded    = ''
      holding_institution_id_number      = ''
      link_to_holding_institution_record = ''
      iiif_manifest                      = ''
      production_date_encoded_008        = ''
      production_place_as_recorded       = ''
      production_date_as_recorded        = ''
      uniform_title_240_as_recorded      = ''
      uniform_title_240_agr              = ''
      title_as_recorded_245              = ''
      title_as_recorded_245_agr          = ''
      genre_as_recorded                  = ''
      subject_as_recorded                = ''
      author_as_recorded                 = ''
      author_as_recorded_agr             = ''
      artist_as_recorded                 = ''
      artist_as_recorded_agr             = ''
      scribe_as_recorded                 = ''
      scribe_as_recorded_agr             = ''
      language_as_recorded               = ''
      language                           = ''
      former_owner_as_recorded           = ''
      former_owner_as_recorded_agr       = ''
      material_as_recorded               = ''
      physical_description               = ''
      binding_description                = ''
      extent_as_recorded                 = ''
      folios                             = ''
      dimensions_as_recorded             = ''
      decoration                         = ''

      data = { source_type:                         source_type,
               holding_institution:                 holding_institution,
               holding_institution_as_recorded:     holding_institution_as_recorded,
               holding_institution_id_number:       holding_institution_id_number,
               link_to_holding_institution_record:  link_to_holding_institution_record,
               iiif_manifest:                       iiif_manifest,
               production_date_encoded_008:         production_date_encoded_008,
               production_place_as_recorded:        production_place_as_recorded,
               production_date_as_recorded:         production_date_as_recorded,
               uniform_title_240_as_recorded:       uniform_title_240_as_recorded,
               uniform_title_240_agr:               uniform_title_240_agr,
               title_as_recorded_245:               title_as_recorded_245,
               title_as_recorded_245_agr:           title_as_recorded_245_agr,
               genre_as_recorded:                   genre_as_recorded,
               subject_as_recorded:                 subject_as_recorded,
               author_as_recorded:                  author_as_recorded,
               author_as_recorded_agr:              author_as_recorded_agr,
               artist_as_recorded:                  artist_as_recorded,
               artist_as_recorded_agr:              artist_as_recorded_agr,
               scribe_as_recorded:                  scribe_as_recorded,
               scribe_as_recorded_agr:              scribe_as_recorded_agr,
               language_as_recorded:                language_as_recorded,
               language:                            language,
               former_owner_as_recorded:            former_owner_as_recorded,
               former_owner_as_recorded_agr:        former_owner_as_recorded_agr,
               material_as_recorded:                material_as_recorded,
               physical_description:                physical_description,
               binding:                             binding_description,
               folios:                              folios,
               extent_as_recorded:                  extent_as_recorded,
               dimensions_as_recorded:              dimensions_as_recorded,
               decoration:                          decoration,
      }

      row << data
    end
  end
end

puts "Wrote: #{output_csv}"
