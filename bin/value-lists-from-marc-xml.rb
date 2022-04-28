#!/usr/bin/env ruby

######
# Script to extract CSV of names for reconciliation from source files
#


require 'nokogiri'
require 'csv'
require 'yaml'
require 'optionparser'
require_relative '../lib/ds'

def names_from_marc files
  data = []
  files.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!
    xml.xpath('//record').each do |record|
      data += DS::MarcXML.extract_name_sets record, tags: [100, 110, 111]
      data += DS::MarcXML.extract_name_sets record, tags: [700, 710], relators: ['artist', 'illuminator', 'scribe', 'former owner']
    end
  end
  data.uniq!
  data.sort { |a,b| a.first <=> b.first }
end

options = {
  out_dir: '.'
}
parser = OptionParser.new do |opts|

  opts.accept :source_type do |value|
    sym = value.to_s.strip.downcase.to_sym
    raise "Unknown source type: '#{value}'" unless DS::SOURCE_TYPES.include? sym
    sym
  end

  opts.accept :institution do |value|
    inst_qid = DS.find_qid value
    raise "Not a known institution: '#{value}'" unless inst_qid
    value.to_s.strip.downcase
  end

  opts.accept :directory do |value|
    raise "Cannot find directory: '#{value}'" unless File.directory? value
    value
  end

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] --institution=INSTITUTION XML [XML ..]

Extract names from DS source files (MARC XML, TEI, METS, CSV)

EOF

  # We can't predictably extract the institution name from MARC records
  inst_help = "Short name for the institution; REQUIRED"
  opts.on('-i INSTITUTION', '--institution=INSTITUTION', :institution, inst_help) do |inst|
    options[:institution] = inst
  end

  # source type
  source_help = "Source data type (one of #{DS::SOURCE_TYPES.join(', ')}); REQUIRED"
  opts.on('-t TYPE', '--source-type=TYPE', :source_type, source_help) do |source|
    options[:source_type] = source
  end

  # directory
  dir_help = "The output directory [default '.']"
  opts.on('-o PATH', '--directory=PATH', :directory, dir_help) do |path|
    options[:out_dir] = path
  end

  help_help = <<~EOF
    Prints this help

    You must provide a value for the '--institution' flag. Values are: #{DS::INSTITUTION_ALIASES.join ', '}

EOF
  opts.on("-h", "--help", help_help) do
    puts opts
    exit
  end
end

begin
  parser.parse!
rescue
  abort $!.message
end

files = ARGV.dup

abort 'Please provide one or more input files' if files.empty?
cannot_find = files.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?
abort "Please provide an --institution value" unless options[:institution]
abort "Please provide a --source-type value" unless options[:source_type]

out_file = File.join options[:out_dir], "#{names}-#{options[:institution]}.csv"
data = []
case options[:source_type]
when DS::MARC_XML
  data = names_from_marc files
else
  raise NotImplementedError, "No method for source type: '#{options[:source_type]}'"
end

header = %w{name name_agr source_authority_uri}
CSV.open out_file, 'wb' do |csv|
  csv << header
  data.each do |row|
    csv << row
  end
end
puts "Wrote: #{out_file}"



