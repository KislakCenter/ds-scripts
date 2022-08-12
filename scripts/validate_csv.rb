#!/usr/bin/env ruby

require 'csv'
require_relative '../lib/ds/csv_util'

##
# Check all CSV values for trailing spaces
csv = ARGV.shift
rows     = CSV.readlines(csv, headers: true).map &:to_h
is_valid = DS::CSVUtil.validate rows

puts "CSV is #{is_valid ? '' : 'not '}valid: '#{csv}'"
