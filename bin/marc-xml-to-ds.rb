#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 CSV format.
#


require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'
require_relative '../lib/ds'

options = {}
OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] --institution=INSTITUTION XML [XML ..]

Generate a DS 2.0 CSV from MARC XML.

EOF

  opts.on('-o FILE', '--output-csv=FILE', "Name of the output CSV file [default: output.csv]") do |output|
    options[:output_csv] = output
  end

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
preferred_name = DS.preferred_inst_name options[:institution]

DEFAULT_FIELD_SEP = '|'
DEFAULT_WORD_SEP  = ' '

output_csv = options[:output_csv] || 'output.csv'

CSV.open output_csv, "w", headers: true do |row|
  row << DS::HEADINGS

  xmls.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!

    records = xml.xpath '//record'

    records.each do |record|
      source_type                        = 'marc-xml'
      holding_institution                = inst_qid
      holding_institution_as_recorded    = DS::MarcXML.extract_institution_name record, default: preferred_name
      holding_institution_id_number      = DS::MarcXML.extract_holding_institution_ids record
      link_to_holding_institution_record = %Q{https://franklin.library.upenn.edu/catalog/FRANKLIN_#{DS::MarcXML.extract_mmsid(record)}}
      iiif_manifest                      = DS::MarcXML.find_iiif_manifest record
      production_date_encoded_008        = DS::MarcXML.extract_encoded_date_008 record
      production_place_as_recorded       = record.xpath("datafield[@tag=260]/subfield[@code='a']").text
      production_date_as_recorded        = record.xpath("datafield[@tag=260]/subfield[@code='c']").text
      uniform_title_240_as_recorded      = record.xpath("datafield[@tag=240]/subfield[@code='a']").text
      uniform_title_240_agr              = DS::MarcXML.extract_title_agr record, 240
      title_as_recorded_245              = DS.clean_string record.xpath("datafield[@tag=245]/subfield[@code='a']").text
      title_as_recorded_245_agr          = DS::MarcXML.extract_title_agr record, 245
      genre_as_recorded                  = DS::MarcXML.collect_datafields record, tags: 655, codes: 'abcvxyz'.split(//), sub_sep: '--'
      subject_as_recorded                = DS::MarcXML.collect_datafields record, tags: [610, 650, 651, 600], codes: ('a'..'z').to_a, sub_sep: '--'
      author_as_recorded                 = DS::MarcXML.extract_names_as_recorded record,      tags: [100]
      author_as_recorded_agr             = DS::MarcXML.extract_names_as_recorded_agr record,  tags: [100]
      artist_as_recorded                 = DS::MarcXML.extract_names_as_recorded record,      tags: [700, 710], relators: ['artist', 'illuminator']
      artist_as_recorded_agr             = DS::MarcXML.extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['artist', 'illuminator']
      scribe_as_recorded                 = DS::MarcXML.extract_names_as_recorded record,      tags: [700, 710], relators: ['scribe']
      scribe_as_recorded_agr             = DS::MarcXML.extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['scribe']
      language_as_recorded               = DS.clean_string record.xpath("datafield[@tag=546]/subfield[@code='a']").text
      language                           = DS::MarcXML.extract_langs record
      former_owner_as_recorded           = DS::MarcXML.extract_names_as_recorded record,      tags: [700, 710], relators: ['former owner']
      former_owner_as_recorded_agr       = DS::MarcXML.extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['former owner']
      material_as_recorded               = DS::MarcXML.collect_datafields record, tags: 300, codes: 'b'
      physical_description               = DS::MarcXML.extract_physical_description record
      binding_description                = DS::MarcXML.extract_named_500 record,  name: 'Binding'
      extent_as_recorded                 = DS::MarcXML.collect_datafields record, tags: 300, codes: 'a'
      folios                             = DS::MarcXML.collect_datafields record, tags: 300, codes: 'a'
      dimensions_as_recorded             = DS::MarcXML.collect_datafields record, tags: 300, codes: 'c'
      decoration                         = DS::MarcXML.extract_named_500 record,  name: 'Decoration'

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