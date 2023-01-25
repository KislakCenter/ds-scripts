#!/usr/bin/env ruby

require 'optparse'
require 'logger'
require 'tempfile'

RECON_SCRIPT = File.join __dir__, '../bin/ds-recon'

LOGGER = Logger.new STDOUT
LOGGER.level = (ENV['DS_LOGLEVEL'] || Logger::DEBUG)

OUT_DIR = File.join __dir__, '../tmp'

def get_input
  return ARGV unless ARGV.first == '-'
  ARGV.clear
  ARGF
end

options = { outdir: OUT_DIR }

ARGV.options do |opts|
  opts.banner = <<~EOF
Usage: #{File.basename __FILE__} [OPTIONS] {FILE [FILE ...]|-}

Generate all recon CSVs for:

Genres, Subjects, Named subjects, Languages, Materials, Names, Places, Titles

  EOF

  t_help = %q{Tag to append to output files (e.g., 'penn')}
  opts.on '-a TAG', '--tag TAG', t_help do |tag|
    options[:tag] = tag
  end

  s_help = %q{The source type (e..g, MARC, METS, TEI)}
  opts.on '-t TYPE', '--source-type TYPE', s_help do |source_type|
    options[:source_type] = source_type
  end

  opts.on '--verbose', 'Be verbose' do |verbose|
    options[:verbose] = verbose
  end

  opts.on '-o DIRECTORY', '--directory DIRECTORY', 'Output directory' do |outdir|
    options[:outdir] = outdir
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    puts <<~EOF

    Use '-' if list of files is piped in.

    EOF
    exit
  end

  opts.parse!
end

abort "--source-type is required" unless options[:source_type]

tmpfile = Tempfile.open('files')
get_input.each { |f| tmpfile.puts f }
tmpfile.close

tstmp = Time.now.strftime '%Y-%d-%m'

command_opts = ""
command_opts << "-t #{options[:source_type]} "
command_opts << "-o #{options[:outdir]} "
command_opts << (options[:tag] ? "-a #{options[:tag]}-#{tstmp} " : "-a #{tstmp} ")
command_opts << '--skip-recon-update '

sub_commands = [
'genres',
'subjects',
'subjects --named-subjects',
'languages',
'materials',
'names',
'places',
'titles',
]

system "#{RECON_SCRIPT} recon-update"

sub_commands.each do |sub|
  cmd = "#{RECON_SCRIPT} #{sub} #{command_opts} -"
  LOGGER.info "Running: #{cmd}"
  system %Q{cat #{tmpfile.path} | #{cmd} }
end



