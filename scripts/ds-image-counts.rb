#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'

# Institutions and their DS IDs
#
# conception    15
# csl           13, 9
# cuny           5
# grolier       24
# gts           23
# indiana       40
# kansas        30
# nelsonatkins  46
# nyu           25
# providence    28
# rutgers        6
# ucb            1, 8, 11
# wellesley     50

inst_ids = {
  15 => 'conception',
  13 => 'csl',
  9  => 'csl',
  5  => 'cuny',
  24 => 'grolier',
  23 => 'gts',
  40 => 'indiana',
  30 => 'kansas',
  46 => 'nelsonatkins',
  25 => 'nyu',
  28 => 'providence',
  6  => 'rutgers',
  1  => 'ucb',
  8  => 'ucb',
  11 => 'ucb',
  50 => 'wellesley',
}

CSV.open('output.csv', 'w') do |csv|
  inst_ids.each do |id, inst|
    uri = "https://digital-scriptorium.org/xtf3/search?rmode=digscript&smode=bid&bid=#{id}&docsPerPage=1000"
    ms_list = URI.open(uri) { |f| Nokogiri::HTML f }
    ms_list.xpath('//td/table[descendant::td/a[@class="headLink1"]]').each do |table|
      callno           = table.xpath('./descendant::td/a[@class="headLink1"]').text.split(/,/).last
      number_available = table.xpath('./descendant::span[starts-with(text(), "Number of Images")]/following-sibling::text()')
      csv << [inst, callno.strip, number_available]
    end
  end
end
