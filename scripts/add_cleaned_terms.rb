require_relative '../lib/ds'
require 'csv'
require 'pry'
require 'pp'

=begin
This script addresses a change in how as_recorded are extracted from
source records and cleaned.

Most recon CSV as_recorded, were generated before string cleaning for
as_recorded values was made uniform across a recon types. This means
that when new import CSVs are generated, as_recorded will be pulled
using the new method and may not match data dictionary strings,
meaning import CSV values that should resolve do not.

For example, old as_recorded value:

  Some value]

New authority value:

  Some value

This script does not alter existing data dictionary values, but adds
new rows with adjusted as_recorded values; for example, given a row
with an as recorded value `paper ;`:

  paper ;,paper,http://vocab.getty.edu/aat/300014109

This script will retain that row and add a new row with as_recorded
value `paper`:

  paper,paper,http://vocab.getty.edu/aat/300014109

=end

PATTERN = /^["\[]+|[\].; "]+$/

input_csv = ARGV.first

headers = CSV.readlines(input_csv).first
out_rows = []

CSV.foreach(input_csv, 'r') do |row|
  out_rows << row.to_a
  first = row.to_a.dup.first

  next if row.to_a.first =~ /as_recorded/
  next if first.nil? || first.empty?

  cleaned = first.split('|').map { |s|
    DS::Util.clean_string s, terminator: ''
  }.join '|'
  unless cleaned == first
    updated = row.to_a.dup

    updated[0] = cleaned
    out_rows << updated
  end
end

out_rows.delete headers
CSV do |csv|
  csv << headers
  # out_rows.sort_by { |row|
  #   row
  # }.uniq.each { |row|
  out_rows.uniq.each { |row|
    csv << row
  }
end