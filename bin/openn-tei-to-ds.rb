#!/usr/bin/env ruby

######
# Script to convert OPenn TEI XML to DS 2.0 CSV format.
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

Generate a DS 2.0 CSV from OPenn TEI XML.

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

CSV.open output_csv, "w", headers: true do |row|
  row << DS::HEADINGS

  xmls.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!

    source_type                        = 'openn-tei'
    holding_institution_as_recorded    = xml.xpath('(//msIdentifier/institution|//msIdentifier/repository)[1]').text
    holding_institution                = DS::INSTITUTION_NAMES_TO_QID.fetch holding_institution_as_recorded, ''
    holding_institution_id_number      = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]').text()
    link_to_holding_institution_record = xml.xpath('//altIdentifier[@type="resource"][1]').text.strip
    production_place_as_recorded       = xml.xpath('//origPlace/text()').map(&:to_s).join '|'
    production_date_as_recorded        = DS::OPennTEI.extract_production_date_as_recorded xml
    production_date                    = production_date_as_recorded
    century                            = DS.transform_date_to_century production_date
    title_as_recorded_245              = xml.xpath('//msItem[1]/title/text()').map(&:to_s).join '|'
    author_as_recorded                 = xml.xpath('//msItem/author/text()').map(&:to_s).join '|'
    author                             = xml.xpath('//msItem/author').map{ |a| a['ref'] }.join '|'
    artist_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'artist'
    artist                             = DS::OPennTEI.extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'artist'
    scribe_as_recorded                 = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'scribe'
    scribe                             = DS::OPennTEI.extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'scribe'
    language_as_recorded               = xml.xpath '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
    language                           = DS::OPennTEI.extract_language_codes xml
    illuminated_initials               = ''
    miniatures                         = ''
    former_owner_as_recorded           = DS::OPennTEI.extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'former owner'
    former_owner                       = DS::OPennTEI.extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'former owner'
    material                           = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/@material').text
    material_as_recorded               = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p').text
    physical_description               = DS::OPennTEI.extract_physical_description xml
    acknowledgements                   = ''
    binding_description                = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()').text
    folios                             = ''
    extent_as_recorded                 = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text
    dimensions                         = ''
    dimensions_as_recorded             = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()').text
    decoration                         = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()').text

    # TODO: BiblioPhilly MSS have keywords (not subjects, genre); include them?

    data = {
      source_type:                        source_type,
      holding_institution:                holding_institution,
      holding_institution_as_recorded:    holding_institution_as_recorded,
      holding_institution_id_number:      holding_institution_id_number,
      link_to_holding_institution_record: link_to_holding_institution_record,
      production_place_as_recorded:       production_place_as_recorded,
      production_date_as_recorded:        production_date_as_recorded,
      production_date:                    production_date,
      century:                            century,
      title_as_recorded_245:              title_as_recorded_245,
      author_as_recorded:                 author_as_recorded,
      author:                             author,
      artist_as_recorded:                 artist_as_recorded,
      artist:                             artist,
      scribe_as_recorded:                 scribe_as_recorded,
      scribe:                             scribe,
      language_as_recorded:               language_as_recorded,
      language:                           language,
      illuminated_initials:               illuminated_initials,
      miniatures:                         miniatures,
      former_owner_as_recorded:           former_owner_as_recorded,
      former_owner:                       former_owner,
      material:                           material,
      material_as_recorded:               material_as_recorded,
      physical_description:               physical_description,
      acknowledgements:                   acknowledgements,
      binding:                            binding_description,
      folios:                             folios,
      extent_as_recorded:                 extent_as_recorded,
      dimensions:                         dimensions,
      dimensions_as_recorded:             dimensions_as_recorded,
      decoration:                         decoration,
    }

    row << data
  end
end

puts "Wrote: #{output_csv}"
