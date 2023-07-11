#!/usr/bin/env ruby

require 'nokogiri'
require 'optparse'

CMD = File.basename __FILE__

def usage
  "Usage: #{CMD} [OPTIONS] TAG [CODE...] FILE [FILE...]"
end

options = { max_count: Float::INFINITY }
OptionParser.new do |parser|
  parser.banner = "#{usage}

Print all MARC datafields in the provided files for the given datafield TAG
and subfield CODE or CODEs. Subfield codes are optional.
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

  parser.on('-f', '--files-only', 'Print only the names of matching files') do
    options[:files_only] = true
  end
end.parse!

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

# buuld xpath query for the any codes given; otherwise, use empty string ''
if codes.empty?
  subfields = ''
else
  subfields = " and ./subfield[#{codes.map { |c|
    "@code='#{c}'"
  }.join(' or ')}]"
end
xpath = "record/datafield[@tag=#{tag}#{subfields}]"
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
      puts "============ #{file} ==========="
      puts node.to_xml
    end
  end
  break if count >= options[:max_count] # not tested whether this is needed
end