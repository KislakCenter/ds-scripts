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

def names_from_mets files
  data = []
  files.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }

    data += DS::DS10.extract_recon_names xml
  end
  data.uniq!
  data.sort { |a,b| a.first <=> b.first }
end

def names_from_tei files
  data = []
  files.each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML(f) }
    xml.remove_namespaces!
    nodes = xml.xpath('//msContents/msItem')
    data += DS::OPennTEI.extract_recon_names xml
  end
  data.uniq!
  data.sort { |a, b| a.first <=> b.first }
end

options = {
  out_dir: '.'
}
parser = OptionParser.new do |opts|

  opts.accept :outfile_tag do |value|
    raise "The --tag value cannot have spaces" if value =~ %r{\s}
    value
  end

  opts.accept :source_type do |value|
    sym = value.to_s.strip.downcase.to_sym
    raise "Unknown source type: '#{value}'" unless DS::SOURCE_TYPES.include? sym
    sym
  end

  opts.accept :directory do |value|
    raise "Cannot find directory: '#{value}'" unless File.directory? value
    value
  end

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] --source-type TYPE XML [XML ..]

Extract names from DS source files (MARC XML, TEI, METS, CSV)

EOF

  tag_help = "Tag to append to output CSV name; e.g., 'penn' => 'name-penn.csv'"
  opts.on('-a TAG', '--tag=TAG', :outfile_tag, tag_help) do |tag|
    options[:outfile_tag] = tag
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

  # verbose
  verb_help = "Print full error messages"
  opts.on('-v', '--verbose', TrueClass, verb_help) do |verbose|
    options[:verbose] = verbose
  end

  help_help = <<~EOF
    Prints this help
EOF
  opts.on("-h", "--help", help_help) do
    # binding.pry
    puts opts
    exit
  end
end

begin
  parser.parse!
rescue
  STDERR.puts $!.backtrace if options[:verbose]
  abort $!.message
end

files = ARGV.dup

abort 'Please provide one or more input files' if files.empty?
cannot_find = files.reject { |f| File.exist?(f) }
abort "Can't find input XML: #{cannot_find.join '; ' }" unless cannot_find.empty?
abort "Please provide a --source-type value" unless options[:source_type]

csv_name = options[:outfile_tag] ? "names-#{options[:outfile_tag]}.csv" : 'names.csv'
out_file = File.join options[:out_dir], csv_name
begin
  case options[:source_type]
  when DS::MARC_XML
    data = names_from_marc files
  when DS::METS_XML
    data = names_from_mets files
  when DS::TEI_XML
    data = names_from_tei files
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
rescue NotImplementedError, StandardError
  STDERR.puts $!.backtrace if options[:verbose]
  abort "#{$!}"
end



