#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/',
}

# We're only interest in these
DEPENDENT_ON_DS = %w{
csl
cuny
conception
gts
grolier
indiana
nyu
providence
rutgers
nelsonatkins
ucb
kansas
wellesley
}

def find_file image_map:, filename:, inst_dir: ''
  base = File.basename filename, '.tif'
  raise "File name does not have expected .tif extension: #{filename}" if base == filename

  # Wellesley has a weird file name conversion
  if inst_dir.downcase == 'wellesley'
    x = "#{base.sub(%r{^dummy}i, 'DivinaCommedia')}.jpg"
    return x if image_map.include? x # return x if html.xpath("//a[@href='#{x}']").size > 0
  end

  s = "#{base}A.jpg"
  return s if image_map.include? s

  s = s.sub %r{^dummy_?}i, ''
  return s if image_map.include? s

  if s =~ %r{^InU-Li_}i
    x = s.sub(%r{^InU-Li_}, '').split(%r{-}).map { |p|
      p =~ %r{^\d+A\.jpg} ? p : p.downcase
    }.join '-'
    return x if image_map.include? x
  end

  s.sub! %r{_(\d+A\.jpg)}, '.\1'
  return s if image_map.include? s

  s.sub! %r{A\.jpg}, '.jpg'
  return s if image_map.include? s

  'NOT_FOUND'
end

# get a list of all the JPEGs for this member institution
def read_images images_list
  images_html = File.open(images_list) { |f| Nokogiri::HTML f }
  images_html.xpath('//table[@id="indexlist"]/tr/td[@class="indexcolicon"][1]/a/@href').map { |href|
    href.text
  }.uniq
end

##
# Trim off the part of before +digitalassets.lib.berkeley.edu+ and return
# a relative path.
def rel_path path
  path.sub %r{^/.*/digitalassets.lib.berkeley.edu}, 'digitalassets.lib.berkeley.edu'
end

##
# Return the relative path to the JPEG file from the directory:
#
#     digitalassets.lib.berkeley.edu/ds/
#
# Returned value will be something like:
#
#     digitalassets.lib.berkeley.edu/ds/gts/images/0000078.jpg
#
# @param [String] inst_dir absolute path to the folder for the institution; e.g.,
#         +/Users/emeryr/NoBackup/ds/digitalassets.lib.berkeley.edu/ds/csl+
# @param [String] jpeg_basename basename of the jpeg file; e.g., +0000078.jpg+
#         or +NOT_FOUND+
# @return [String] the relative path to the image file or +NOT_FOUND+ if no
#         JPEG was found; e.g.,
#         +digitalassets.lib.berkeley.edu/ds/gts/images/0000078.jpg+
def get_found_path inst_dir, jpeg_basename
  return jpeg_basename if jpeg_basename == 'NOT_FOUND'

  # get the relative path to the jpeg; e.g.,
  #   digitalassets.lib.berkeley.edu/ds/gts/images/0000078.jpg
  rel_path(File.join inst_dir, 'images', jpeg_basename)
end

##
# Argument is the folder path to the folder containing the institution folders:
#
#     digitalassets.lib.berkeley.edu/ds
#
# Cycle through the DEPENDENT_ON_DS list and for each institution folder get
# `images/index.html` (which lists all the files in the `images` directory).
# Then cycle through all the METS XML files in each `mets` dir and find the
# names of the corresponding images  in `index.html`
output_file = "output.csv"
ds_dir = ARGV.shift
HEADER = %w{ inst mets_path mets_basename dmdsec_id mets_image_filename jpeg }
CSV.open(output_file, 'w+') do |csv|
  csv << HEADER
  DEPENDENT_ON_DS.each do |inst|
    inst_dir = File.join ds_dir, inst
    STDERR.puts "Processing: '#{inst_dir}'"
    images_list = "#{inst_dir}/images/index.html" # path to the image list; like `digitalassets.lib.berkeley.edu/ds/missouri/images/index.html`
    image_map   = read_images images_list         # an array of all the JPEGs listed in index.html
    # all the mets files; e.g., `digitalassets.lib.berkeley.edu/ds/missouri/mets/*.xml`
    Dir["#{inst_dir}/mets/*.xml"].each do |mets_xml|
      xml = File.open(mets_xml) { |f| Nokogiri::XML f }
      # cycle through every `mets:dmdSec` element with a filename
      # //mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]
      #
      # <mets:dmdSec ID="DM4">
      #  <mets:mdWrap MDTYPE="MODS" LABEL="Opening initial and heading.">
      #   <mets:xmlData>
      #     <mods:mods>
      #
      #      <mods:titleInfo>
      #       <mods:title>Opening initial and heading.</mods:title>
      #      </mods:titleInfo>
      #      <mods:titleInfo type="alternative" displayLabel="Caption">
      #       <mods:title>Opening initial and heading.</mods:title>
      #      </mods:titleInfo>
      #      <mods:typeOfResource>text</mods:typeOfResource>
      #      <mods:physicalDescription>
      #      <mods:extent>f. 1r</mods:extent>
      #      </mods:physicalDescription>
      #       <mods:identifier type="filename" displayLabel="Filename">DS003686a.tif</mods:identifier>
      #    <mods:location>
      #     <mods:physicalLocation>McEnerney Law Library;;, Robbins Collection, School of Law (Boalt Hall), University of California, Berkeley, CA 94720-7200;;, URL: http://www.law.berkeley.edu/robbins/</mods:physicalLocation>
      #    </mods:location>
      #     </mods:mods>
      #   </mets:xmlData>
      #  </mets:mdWrap>
      # </mets:dmdSec>

      xml.xpath('//mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]', NS).each do |node|
        dmdsec_id = node['ID']
        node.xpath("mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type='filename']", NS).each do |filename|
          # found_base is a file basename present in the image_map; e.g.,
          #     0000078.jpg
          found_base = find_file image_map: image_map, filename: filename, inst_dir: inst
          # relative path to the found file; e.g.,
          #     digitalassets.lib.berkeley.edu/ds/gts/images/0000078.jpg
          found_path = get_found_path inst_dir, found_base

          # mets_path is the relative path to the METS file; e.g.,
          #     digitalassets.lib.berkeley.edu/ds/gts/mets/ds_50_23_00148750.xml
          mets_path = rel_path mets_xml
          # mets_base is the base METS filename; e.g., ds_50_23_00148750.xml
          mets_base = File.basename mets_xml

          csv << [inst, mets_path, mets_base, dmdsec_id, filename, found_path]
        end
      end
    end
  end
end
