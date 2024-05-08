#!/usr/bin/env ruby

require 'csv'

require_relative '../lib/ds'

##
# Script to generate a CSV of mods:abstracts from DS METS
#

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/',
}

HEADERS = %i{
  shelfmark
  institution
  label
  name
  sourcefile
}

def select_input args
  return args unless args == ['-']
  ARGV.clear
  ARGF
end

CSV do |csv|
  csv << HEADERS
  select_input(ARGV).each do |in_xml|
    source_file = in_xml.chomp
    xml         = File.open(source_file) { |f| Nokogiri::XML f }
    institution = source_file.split('/')[3]
    xpath       = '//mods:abstract'
    shelfmark  = DS::Extractor::DsMetsXml.extract_shelfmark xml

    xml.xpath(xpath).each do |node|
      label = node.xpath('./@displayLabel').text
      text = node.xpath('./text()').text
      csv << [shelfmark, institution, label, text, source_file]
    end
  end
end
