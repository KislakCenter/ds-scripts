#!/usr/bin/env ruby

######
# Script to convert OPenn TEI XML to DS 2.0 CSV format.
#

require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'
require_relative '../lib/ds'

##
# From the given set of nodes, extract the names from all the respStmts with
# resp text == type.
#
# @param [Nokogiri::XML:NodeSet] :nodes the nodes to search for +respStmt+s
# @param [Array<String>] :types a list of types; e.g., +artist+, <tt>former
#         owner</tt>
# @return [String] pipe-separated list of names
def extract_resp_names nodes: , types: []
  return '' if types.empty?
  _types = [types].flatten.map &:to_s
  type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
  xpath = %Q{//respStmt[#{type_query}]}
  nodes.xpath(xpath).map { |rs| rs.xpath('persName/text()') }.join '|'
end

##
# From the given set of nodes, extract the URIs from all the respStmts with
# resp text == type.
#
# @param [Nokogiri::XML:NodeSet] :nodes the nodes to search for +respStmt+s
# @param [Array<String>] :types a list of types; e.g., +artist+, <tt>former
#         owner</tt>
# @return [String] pipe-separated list of URIs
def extract_resp_ids nodes: , types: []
  return '' if types.empty?
  _types = [types].flatten.map &:to_s
  type_query = _types.map { |t| %Q{contains(./resp/text(), '#{t}')} }.join ' or '
  xpath = %Q{//respStmt[#{type_query}]}
  nodes.xpath(xpath).map { |rs| rs.xpath('persName/@ref') }.join '|'
end

def extract_language_codes xml
  xpath = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@mainLang | /TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/@otherLangs'
  xml.xpath(xpath).flat_map { |lang| lang.value.split }.join '|'
end

##
# @param [Nokogiri::XML::Node] :xml the TEI xml
# @return [String]
def extract_collation xml
  formula    = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/collation/p[not(catchwords)]/text()').text
  catchwords = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/collation/p/catchwords/text()').text
  s          = ''
  s          += "Collation: #{formula.strip}. " unless formula.strip.empty?
  s          += "#{catchwords.strip}"           unless catchwords.strip.empty?

  s.strip
end

##
# @param [Nokogiri::XML::Node] :xml the TEI xml
# @return [String]
def extract_physical_description xml
  parts = []
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p/text()')
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/extent/text()')
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/foliation/text()')
  parts << extract_collation(xml)
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/layoutDesc/layout/text()')
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/scriptDesc/scriptNote/text()')
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/decoDesc/decoNote[not(@n)]/text()')
  parts << xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/bindingDesc/binding/p/text()')
  parts.flatten.map { |x| x.to_s.strip }.reject(&:empty?).join '. '
end

options = {}
OptionParser.new do |opts|

  opts.banner = "Usage: #{File.basename __FILE__} [options] XML [XML ..]"

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
    holding_institution                = DS::INSTITUTION_IDS_BY_NAME.fetch holding_institution_as_recorded, ''
    holding_institution_id_number      = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno[@type="call-number"]').text()
    link_to_holding_institution_record = xml.xpath('//altIdentifier[@type="resource"][1]').text.strip
    production_place_as_recorded       = xml.xpath('//origPlace/text()').map(&:to_s).join '|'
    production_date_as_recorded        = xml.xpath('//origDate/@notBefore | //origDate/@notAfter').map(&:to_s).join '-'
    production_date                    = production_date_as_recorded
    title_as_recorded_245              = xml.xpath('//msItem[1]/title/text()').map(&:to_s).join '|'
    author_as_recorded                 = xml.xpath('//msItem/author/text()').map(&:to_s).join '|'
    author                             = xml.xpath('//msItem/author/@ref').map(&:to_s).join '|'
    artist_as_recorded                 = extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'artist'
    artist                             = extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'artist'
    scribe_as_recorded                 = extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'scribe'
    scribe                             = extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'scribe'
    language_as_recorded               = xml.xpath '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/textLang/text()'
    language                           = extract_language_codes xml
    illuminated_initials               = ''
    miniatures                         = ''
    former_owner_as_recorded           = extract_resp_names nodes: xml.xpath('//msContents/msItem'), types: 'former owner'
    former_owner                       = extract_resp_ids nodes: xml.xpath('//msContents/msItem'), types: 'former owner'
    material                           = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/@material').text
    material_as_recorded               = xml.xpath('/TEI/teiHeader/fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc/support/p').text
    physical_description               = extract_physical_description xml
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
