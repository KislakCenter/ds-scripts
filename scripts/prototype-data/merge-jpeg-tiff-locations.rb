#!/usr/bin/env ruby

require 'csv'

require_relative '../lib/ds'

##
# Usage: merge_sheets.rb JPEG_CSV TIFF_CSV

jpeg_csv = ARGV.shift
tiff_csv = ARGV.shift

##
# Create a key from the row by combining the values from the array of columns.
#
#    head1,head2,head3
#    a,b,c
#    1,2,3
#
#    make_key ['head1', 'head3'], row => "a-c" and "1-3"
def make_key columns, row
  columns.map { |k| row[k].to_s.strip }.join('-')
end

key_columns = %w{ mets_path mets_image_filename}

# Create a hash of all the TIFFs
TIFFS = CSV.readlines(tiff_csv, headers: true).inject({}) { |hash,row|
  key = make_key key_columns, row
  hash.update({ key => row['tif'] })
}.freeze

headers = CSV.readlines(jpeg_csv).first + ['tiff']

outfile = 'output.csv'
CSV.open outfile, 'w+', headers: true do |csv|
  csv << headers
  CSV.foreach jpeg_csv, headers: true do |in_row|
    out_row = in_row.dup
    key = make_key key_columns, in_row
    out_row['tiff'] = TIFFS[key]
    csv << out_row
  end
end

STDERR.puts "Wrote #{outfile}"