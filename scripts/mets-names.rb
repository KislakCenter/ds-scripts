#!/usr/bin/env ruby

require 'csv'

require_relative '../lib/ds'

##
# Script to generate a CSV of mods:name data from DS METS
#

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/',
}

HEADERS = %i{
  shelfmark
  institution
  role
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
    xml         = File.open(source_file) { |f| Nokogiri::XML(f) }
    institution = source_file.split('/')[3]
    xpath       = '//mods:name'
    shelfmark  = DS::Extractor::DS10.extract_shelfmark xml
    xml.xpath(xpath).each do |node|
      role = node.xpath('./mods:role/mods:roleTerm').text
      name = node.xpath('./mods:namePart').text
      csv << [shelfmark, institution, role, name, source_file]
    end
  end
end