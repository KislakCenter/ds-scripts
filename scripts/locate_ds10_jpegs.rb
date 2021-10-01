#!/usr/bin/env ruby

require 'nokogiri'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/',
}

def find_file html:, filename:, inst_dir: ''
  base = File.basename filename, '.tif'
  raise "File name does not have expected .tif extension: #{filename}" if base == filename

  # Wellesley has a weird file name conversion
  if inst_dir.downcase == 'wellesley'
    x = "#{base.sub(%r{^dummy}i, 'DivinaCommedia')}.jpg"
    return x if html.xpath("//a[@href='#{x}']").size > 0
  end
  
  s = "#{base}A.jpg"
  return s if html.xpath("//a[@href='#{s}']").size > 0

  s = s.sub %r{^dummy_?}i, ''
  return s if html.xpath("//a[@href='#{s}']").size > 0

  if s =~ %r{^InU-Li_}i
    x = s.sub(%r{^InU-Li_}, '').split(%r{-}).map { |p|
      p =~ %r{^\d+A\.jpg} ? p : p.downcase
    }.join '-'
    return x if html.xpath("//a[@href='#{x}']").size > 0
  end

  s.sub! %r{_(\d+A\.jpg)}, '.\1'
  return s if html.xpath("//a[@href='#{s}']").size > 0

  s.sub! %r{A\.jpg}, '.jpg'
  return s if html.xpath("//a[@href='#{s}']").size > 0
end

##
# Argument is a list of directories like:
#
#     digitalassets.lib.berkeley.edu/ds/missouri digitalassets.lib.berkeley.edu/ds/wellesley ... etc. ...
#
# Each diretory is expected to have this structure:
#
#     digitalassets.lib.berkeley.edu/ds/missouri
#     ├── images
#     └── mets
#
# Cycle through the directories and for each get `images/index.html` (which
# lists) all the files in the `images` directory.
# Then cycle through all the METS XML files in each `mets` dir and find the
# names of the corresponding images `index.html`
ARGV.each do |inst_dir|
  inst                  = File.basename inst_dir              # get the institution folder name; like 'missouri' or `ucb`
  images_list           = "#{inst_dir}/images/index.html"     # path to the image list; like `digitalassets.lib.berkeley.edu/ds/missouri/images/index.html`
  images_html           = File.open(images_list) { |f| Nokogiri::HTML f }
  # all the mets files; e.g., `digitalassets.lib.berkeley.edu/ds/missouri/mets/*.xml`
  Dir["#{inst_dir}/mets/*.xml"].each do |in_xml|
    xml = File.open(in_xml) { |f| Nokogiri::XML f }
    # cycle through every `mets:xmlData` element with a filename
    xml.xpath('//mets:xmlData/mods:mods/mods:identifier[@type="filename"]/text()', NS).each do |filename|
      found_file = find_file html: images_html, filename: filename, inst_dir: inst
      found_file = 'NOT_FOUND' if found_file.to_s.strip.empty?
      puts sprintf("%-10s %-40s %-45s %s", inst, File.basename(in_xml), filename, found_file)
    end
  end
end
