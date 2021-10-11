#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'

CSV.open('output.csv', 'w') do |csv|
  csv << %w{ inst callno count }
  DS::INSTITUTION_DS_IDS.each do |id, inst|
    institutions[inst] ||= {}
    uri = "https://digital-scriptorium.org/xtf3/search?rmode=digscript&smode=bid&bid=#{id}&docsPerPage=1000"
    ms_list = URI.open(uri) { |f| Nokogiri::HTML f }
    ms_list.xpath('//td/table[descendant::td/a[@class="headLink1"]]').each do |table|
      callno           = table.xpath('./descendant::td/a[@class="headLink1"]').text.split(/,/).last
      number_available = table.xpath('./descendant::span[starts-with(text(), "Number of Images")]/following-sibling::text()')
      csv << [inst, callno.strip, number_available]
    end
  end
end
