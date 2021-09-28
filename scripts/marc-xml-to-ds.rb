#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 format.
#

##
#  Questions
#
# LJs 235 does not have an 099 field; where should the shelfmark come from?
# Vernacular script handling?
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

xmls = ARGV.dup

abort 'Please provide an input XML' if xmls.empty?
cannot_find = xmls.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?

DEFAULT_FIELD_SEP = '|'
DEFAULT_WORD_SEP  = ' '

# TODO: Extract methods to a separate module as with DS::DS10

###
# Extract the language codes from controlfield 008 and datafield 041$a.
#
# @param [Nokogiri::XML::Node] :record the marc:record node
# @return [String]
def extract_langs record
  (langs ||= []) << record.xpath("substring(controlfield[@tag='008']/text(), 36, 3)")
  langs += record.xpath("datafield[@tag=041]/subfield[@code='a']").map(&:text)
  langs.uniq.join '|'
end

###
# Extract the encoded date from controlfield 008.
#
# @param [Nokogiri::XML::Node] :record the +marc:record+ node
# @return [String]
def extract_encoded_date_008 record
  record.xpath "substring(controlfield[@tag='008']/text(), 7,9)"
end

##
# Extract names from record using tags and relators. Tags understood are +100+,
# +700+, and +710+. The +relators+ are used to require datafields based on the
# contents of a subfield code +e+ containing the specified value, like 'scribe':
#
#     contains(./subfield[@code ='e'], 'scribe')
#
# @see #build_name_query for details on query construction
#
# @param [Nokogiri::XML:Node] :record a +<marc:record>+ node
# @param [Array<String>] :tags the MARC field code[s]
# @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
def extract_names_as_recorded record, tags: [], relators: []
  xpath = build_name_query tags: tags, relators: relators
  return '' if xpath.empty? # don't process nonsensical requests

  record.xpath(xpath).map { |datafield|
    extract_pn datafield
  }.join '|'
end

##
# Extract the alternate graphical representation of the name or return +''+.
#
# See MARC specification for 880 fields:
#
# * https://www.loc.gov/marc/bibliographic/bd880.html
#
# @see #build_name_query for details on query construction
#
# @param [Nokogiri::XML:Node] :record a +<marc:record>+ node
# @param [Array<String>] :tags the MARC field code[s]
# @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
def extract_names_as_recorded_agr record, tags: [], relators: []
  xpath = build_name_query tags: tags, relators: relators
  return '' if xpath.empty? # don't process nonsensical requests

  record.xpath(xpath).map { |datafield|
    extract_pn_agr datafield
  }.join '|'
end

##
# Build names query tags and relators. Tags understood are +100+, +700+,
# and +710+. The +relators+ are used to require datafields based on the contents
# of a subfield code +e+ containing the specified value, like 'scribe':
#
#     contains(./subfield[@code ='e'], 'scribe')
#
# For relators see section <strong>$e - Relator term<strong>, here:
#
#   https://www.loc.gov/marc/bibliographic/bdx00.html
#
# To require the subfield not have a relator, pass +:none+ as the relator value.
#
#     build_name_query tags: ['100'], relators: :none
#
# This will add the following to the query.
#
#     not(./subfield[@code = 'e'])
#
# Note: In U. Penn manuscript catalog records, 700 and 710 fields that *do*
# *not* have a subfield code +e+ are associated authors.
#
# @param [Array<String>] :tags the MARC field code[s]
# @param [Array<String>] :relators for +700$e+, +710$e+, a value[s] like 'former owner'
# @return [String] the data field query string
def build_name_query tags: [], relators: []
  return '' if tags.empty? # don't process nonsensical requests
  # make sure the tags are all strings
  _tags        = [tags].flatten.map &:to_s
  tag_query    = _tags.map { |t| "@tag = #{t}" }.join " or "
  query_string = "(#{tag_query})"

  _relators    = [relators].flatten.map { |r| r.to_s.strip.downcase == 'none' ? :none : r }
  return "datafield[#{query_string}]" if _relators.empty?

  if _relators.include? :none
    query_string += " and not(./subfield[@code = 'e'])"
    return "datafield[#{query_string}]"
  end

  relator_string = relators.map { |r| "contains(./subfield[@code ='e'], '#{r}')" }.join " or "
  query_string   += (relator_string.empty? ? '' : " and (#{relator_string})")
  "datafield[#{query_string}]"
end

###
# Extract the encoded date from controlfield 008.
#
# @param [Nokogiri::XML::Node] :datafield the +marc:datafield+ node with the name
# @return [String]
def extract_pn datafield
  codes = %w{ a b c d }
  collect_subfields datafield, codes: codes
end

##
# Extract the alternate graphical representation of the name or return +''+.
#
# See MARC specification for 880 fields:
#
# * https://www.loc.gov/marc/bibliographic/bd880.html
#
# Input will look like this:
#
#     <marc:datafield ind1="1" ind2=" " tag="100">
#       <marc:subfield code="6">880-01</marc:subfield>
#       <marc:subfield code="a">Urmawī, ʻAbd al-Muʼmin ibn Yūsuf,</marc:subfield>
#       <marc:subfield code="d">approximately 1216-1294.</marc:subfield>
#     </marc:datafield>
#     <!-- ... -->
#     <marc:datafield ind1="1" ind2=" " tag="880">
#       <marc:subfield code="6">100-01//r</marc:subfield>
#       <marc:subfield code="a">ارموي، عبد المؤمن بن يوسف،</marc:subfield>
#       <marc:subfield code="d">اپرxمتلي 12161294.</marc:subfield>
#     </marc:datafield>
#
# @param [Nokogiri::XML::Node] :datafield the main data field @tag = '100', '700', etc.
# @return [String] the text representation of the value
def extract_pn_agr datafield
  linkage = datafield.xpath("subfield[@code='6']").text
  return '' if linkage.empty?
  tag   = datafield.xpath('./@tag').text
  index = linkage.split('-').last
  xpath = "./parent::record/datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]"
  extract_pn datafield.xpath(xpath)
end

def collect_datafields record, tags: [], codes: [], field_sep:  '|', sub_sep: ' '
  _tags        = [tags].flatten.map &:to_s
  tag_query    = _tags.map { |t| "@tag = #{t}" }.join " or "
  # binding.pry
  record.xpath("datafield[#{tag_query}]").map { |datafield|
    collect_subfields datafield, codes: codes, sub_sep: sub_sep
  }.join field_sep
end

def collect_subfields datafield, codes: [], sub_sep: ' '
  # ensure that +codes+ is an array of strings
  _codes = [codes].flatten.map &:to_s
  # ['a', 'b', 'd', 'c'] => @code = 'a' or @code = 'b' or @code = 'c' or @code = 'd'
  code_query = _codes.map { |code| "@code = '#{code}'" }.join ' or '
  xpath      = %Q{subfield[#{code_query}]}
  datafield.xpath(xpath).map(&:text).reject(&:empty?).join sub_sep
end

def extract_title_agr record, tag
  linkage = record.xpath("datafield[@tag=#{tag}]/subfield[@code='6']").text
  return '' if linkage.empty?
  index = linkage.split('-').last
  xpath = "datafield[@tag='880' and contains(./subfield[@code='6'], '#{tag}-#{index}')]/subfield[@code='a']"
  record.xpath(xpath).text
end

def extract_physical_description record
  parts = []
  extent = record.xpath("datafield[@tag=300]").map { |datafield|
    xpath = "subfield[@code = 'a' or @code = 'b' or @code = 'c']"
    datafield.xpath(xpath).map(&:text).reject(&:empty?).join ' '
  }.join ' '
  parts << "Extent: #{extent}" unless extent.strip.empty?
  parts << extract_named_500(record, name: 'Collation')
  parts << extract_named_500(record, name: 'Layout')
  parts << extract_named_500(record, name: 'Script')
  parts << extract_named_500(record, name: 'Decoration')
  parts << extract_named_500(record, name: 'Binding')
  parts.flatten.map(&:strip).join ' '
end

# We don't have a good way to look these up, so I'm hard-coding the addresses.
# TODO: Make IIIF manifest mapping configurable or dynamic
IIIF_MANIFESTS = {
  '9947675343503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3k649t48/manifest',
  '9947675343503681-test' => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3k649t48/manifest',
  '9950569233503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3zm0w/manifest',
  '9952666523503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p37w6764x/manifest',
  '9959647633503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3mp74/manifest',
  '9965025663503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3h00n/manifest',
  '9976106713503681'      => 'https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3n29p909/manifest',
}

def find_iiif_manifest record
  mmsid = extract_mmsid record
  IIIF_MANIFESTS[mmsid.to_s]
end

def extract_holding_institution_ids record
  # start with the shelfmark
  ids = [find_shelfmark(record)]
  # add the MMS ID
  ids << extract_mmsid(record)

  ids.reject(&:empty?).join '|'
end

def find_shelfmark record
  callno = record.xpath('holdings/holding/call_number').text
  return callno unless callno.strip.empty?

  callno = record.xpath("datafield[@tag=99]/subfield[@code='a']").text
  return callno unless callno.strip.empty?

  # Princeton call number
  xpath = "datafield[@tag=852 and subfield[@code='b']/text() = 'hsvm']/subfield[@code='h']"
  callno = record.xpath(xpath).text
  return callno unless callno.strip.empty?

  xpath = "datafield[@tag='500']/subfield[@code='a' and starts-with(text(), 'Shelfmark:')]"
  callno = record.xpath(xpath).text
  return callno.sub(%r{^Shelfmark:\s*}, '') unless callno.strip.empty?

  # return empty string if we get this far
  ''
end

def extract_mmsid record
  record.xpath("controlfield[@tag=001]").text
end

def extract_named_500 record, name:
  return '' if name.to_s.strip.empty?

  xpath = "datafield[@tag=500]/subfield[@code='a' and starts-with(./text(), '#{name}')]"
  record.xpath(xpath).map { |d| d.text.sub(%r{^#{name}:?\s*}, '').strip }.join ' '
end

output_csv = options[:output_csv] || 'output.csv'

CSV.open output_csv, "w", headers: true do |row|
  row << DS::HEADINGS

  xmls.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!

    records = xml.xpath '//record'

    records.each do |record|
      source_type                        = 'marc-xml'
      holding_institution                = %q{https://www.wikidata.org/wiki/Q49117}
      holding_institution_as_recorded    = record.xpath("datafield[@tag=852]/subfield[@code='a']").text
      holding_institution_id_number      = extract_holding_institution_ids record
      link_to_holding_institution_record = %Q{https://franklin.library.upenn.edu/catalog/FRANKLIN_#{extract_mmsid(record)}}
      iiif_manifest                      = find_iiif_manifest record
      production_date_encoded_008        = extract_encoded_date_008 record
      production_place_as_recorded       = record.xpath("datafield[@tag=260]/subfield[@code='a']").text
      production_date_as_recorded        = record.xpath("datafield[@tag=260]/subfield[@code='c']").text
      uniform_title_240_as_recorded      = record.xpath("datafield[@tag=240]/subfield[@code='a']").text
      uniform_title_240_agr              = extract_title_agr record, 240
      title_as_recorded_245              = record.xpath("datafield[@tag=245]/subfield[@code='a']").text
      title_as_recorded_245_agr          = extract_title_agr record, 245
      genre_as_recorded                  = collect_datafields record, tags: 655, codes: 'abcvxyz'.split(//), sub_sep: '--'
      subject_as_recorded                = collect_datafields record, tags: [610, 650, 651, 600], codes: ('a'..'z').to_a, sub_sep: '--'
      author_as_recorded                 = extract_names_as_recorded record,      tags: [100]
      author_as_recorded_agr             = extract_names_as_recorded_agr record,  tags: [100]
      artist_as_recorded                 = extract_names_as_recorded record,      tags: [700, 710], relators: ['artist', 'illuminator']
      artist_as_recorded_agr             = extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['artist', 'illuminator']
      scribe_as_recorded                 = extract_names_as_recorded record,      tags: [700, 710], relators: ['scribe']
      scribe_as_recorded_agr             = extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['scribe']
      language_as_recorded               = record.xpath("datafield[@tag=546]/subfield[@code='a']").text
      language                           = extract_langs record
      former_owner_as_recorded           = extract_names_as_recorded record,      tags: [700, 710], relators: ['former owner']
      former_owner_as_recorded_agr       = extract_names_as_recorded_agr record,  tags: [700, 710], relators: ['former owner']
      material_as_recorded               = collect_datafields record, tags: 300, codes: 'b'
      physical_description               = extract_physical_description record
      binding_description                = extract_named_500 record,  name: 'Binding'
      extent_as_recorded                 = collect_datafields record, tags: 300, codes: 'a'
      folios                             = collect_datafields record, tags: 300, codes: 'a'
      dimensions_as_recorded             = collect_datafields record, tags: 300, codes: 'c'
      decoration                         = extract_named_500 record,  name: 'Decoration'

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
