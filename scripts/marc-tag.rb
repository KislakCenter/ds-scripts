#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'

# Script to find MARC records for a given TAG and, optionally subfield codes

CMD = File.basename __FILE__

def usage
  "Usage: #{CMD} [OPTIONS] TAG [CODE...] FILE [FILE...]"
end


# Return true if user has passed a contains option
# @param [Hash<Symbol,Object>] options the parsed options hash
def contains_query? options
  contains_keys = %i{ contains contains_insensitive }
  options.keys.any? { |k| contains_keys.include? k }
end

def subfield_query? codes, options
  return true if codes.any?
  contains_query? options
end

def build_codes_query codes
  return if codes.none?
  codes.map { |code| "@code = '#{code}'" }.join(' or ')
end

def build_subfield_query codes, options
  return '' unless subfield_query? codes, options

  # query = []
  base_query = codes.any? ? "./subfield[#{build_codes_query codes}]" : '.'
  query = ''
  if options[:contains_insensitive]
    "and contains(translate(#{base_query},"\
             " 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',"\
             " 'abcdefghijklmnopqrstuvwxyz'),"\
             "'#{options[:contains_insensitive].downcase}')"
  elsif options[:contains]
    " and contains(#{base_query}, '#{options[:contains]}')"
  else
    " and #{base_query}"
  end
end

options = { max_count: Float::INFINITY }
OptionParser.new do |parser|
  parser.banner = "#{usage}

Print all MARC datafields in the provided files for the given datafield TAG
and subfield CODE or CODEs. Subfield codes are optional.

Note that the -c/--contains matches subfields having CODE or CODEs; when no
CODE is specified, all subfields will be tested for contains.
  "

  parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  parser.on("-h", "--help", "Print this help") do
    puts parser
    exit
  end

  parser.on('-mCOUNT', '--max-files=COUNT', Integer,
            'Maximum number of files with matching datafields to print') do |count|
    options[:max_count] = count
  end

  parser.on('-l', '--list-files', 'Print only the names of matching files') do
    options[:files_only] = true
  end

  parser.on('-cSTRING', '--contains=STRING',
           'Return datafields with subfield(s) containing STRING') do |s|
    options[:contains] = s
  end

  parser.on('-CSTRING', '--contains-insensitive=STRING',
            'Case insensitive contains') do |s|
    options[:contains_insensitive] = s
  end

end.parse!
puts "Options are: #{options.inspect}" if options[:verbose]
##

# INPUT
##
# the datafield tag
tag = ARGV.shift
unless tag =~ %r{^\d{3}$}
  usage
  puts
  abort "Tag should be a 3-digit number: '#{tag}'"
end

# all single lower case letters and single digits are codes
codes = []
codes << ARGV.shift while ARGV.first =~ %r{^[a-z0-9]$}

# assume the rest are files
files = ARGV

if tag =~ /^00[135678]/
  xpath = "//record/controlfield[@tag=#{tag}#{build_subfield_query codes, options}]"
else
  xpath = "//record/datafield[@tag=#{tag}#{build_subfield_query codes, options}]"
end
puts "Using xpath: #{xpath}" if options[:verbose]

# set a counter in case there's a limit
count = 0
files.each do |file|
  xml = File.open(file) { |f| Nokogiri::XML(f) }
  xml.remove_namespaces!
  xml.xpath(xpath).each_with_index do |node, ndx|
    count += 1 if ndx == 0
    if options[:files_only]
      puts file
    else
      puts "============ #{file} ===========" if ndx == 0
      puts node.to_xml
    end
  end
  break if count >= options[:max_count] # not tested whether this is needed
end