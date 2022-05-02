require 'csv'
require 'optionparser'

options = {
  out_file: 'output.csv'
}
parser = OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options] --institution=INSTITUTION XML [XML ..]

Concatenate CSVs.

EOF

  # directory
  out_help = "The output file [default 'output.csv']"
  opts.on('-o file', '--outfile=FILE', out_help) do |path|
    options[:out_file] = path
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

parser.parse!

rows = []

csvs = ARGV.dup

header = CSV.readlines(csvs.first).first

data = []
csvs.each do |in_file|
  data += CSV.readlines(in_file)[1..-1]
end

data.sort_by! &:first
data.uniq!

CSV.open options[:out_file], 'wb', headers: true do |csv|
  csv << header
  data.each do |row|
    csv << row
  end
end

puts "Wrote: #{options[:out_file]}"