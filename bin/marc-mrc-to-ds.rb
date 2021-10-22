#!/usr/bin/env ruby

######
# Script to convert UPenn Marc XML to DS 2.0 CSV format.
#


require 'marc'
require 'csv'
require 'optionparser'
require_relative '../lib/ds'

options = {}
options[:directory] = '.'
options[:prefix]    = ''
options[:encoding]  = 'UTF-8'

OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] MRC [MRC ..]

Convert MARC MRC to MARC XML.

EOF

  p_help = "String prefix for file name; e.g., 'inst-marc-' [default: #{options[:prefix]}]"
  opts.on('-p PREFIX', '--prefix=PREFIX', p_help) do |prefix|
    options[:prefix] = prefix
  end

  d_help = "Path of an directory to output XML files to [default: #{options[:directory]}"
  opts.on('-d PATH', '--directory=PAGE', d_help) do |directory|
    options[:directory] = directory
  end

  e_help = "Encoding of the incoming MARC MRC/DAT file: [default: #{options[:encoding]}]"
  opts.on('-e ENCODING', '--marc-encoding=ENCODING', e_help) do |encoding|
    options[:encoding] = encoding
  end

  l_help = "List encodings available on this computer; WARNING: long list"
  opts.on('-l', '--list-encodings', l_help) do
    puts "Known encodings: "
    puts Encoding.list.map { |enc| enc.names.join ', ' }
    exit
  end

  h_help = <<~EOF
Prints this help

Note on encodings: Legacy MARC files can use MARC-8. If the default fails, 
try that. To see a list of available encodings (a long list). Use the -l option.
EOF
  opts.on("-h", "--help", h_help) do
    puts opts
    exit
  end
end.parse!

marc_mrc = ARGV.dup

abort 'Please provide an input MRC' if marc_mrc.empty?
cannot_find = marc_mrc.reject { |f| File.exist?(f) }
abort "Can't find input MRC: #{cannot_find.join '; ' }" unless cannot_find.empty?
abort "Cannot find output path: #{options[:directory]}" unless File.directory? options[:directory]

marc_mrc.each do |mrc|
  reader = MARC::Reader.new(mrc, :external_encoding => "UTF-8")
  reader.each_with_index do |record,ndx|
    base     = sprintf '%s%03d.xml', options[:prefix], ndx
    marc_out = File.join options[:directory], base
    File.open(marc_out, 'w+') { |f| f.puts record.to_xml }
    puts "Wrote #{marc_out}"
  end
end
