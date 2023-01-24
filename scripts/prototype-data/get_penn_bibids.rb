#!/usr/bin/env ruby

# Extract bibids from OPenn TEI file. Argument is a file of OPenn TEI urls,
# like:
#
# https://openn.library.upenn.edu/Data/0002/mscoll390_item1/data/mscoll390_item1_TEI.xml

require 'nokogiri'
require 'open-uri'

ARGF.each do |url|
  xml = URI.open(url.strip) { |f| Nokogiri::XML f }
  ns = { 't' => 'http://www.tei-c.org/ns/1.0' }
  puts xml.xpath('//t:altIdentifier[@type="bibid"]/t:idno', ns).text.strip
end