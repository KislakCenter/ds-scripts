#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'

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
output_file = "output.csv"
CSV.open(output_file, 'w+') do |csv|
  ARGV.each do |inst_dir|
    STDERR.puts inst_dir
    inst                  = File.basename inst_dir              # get the institution folder name; like 'missouri' or `ucb`
    images_list           = "#{inst_dir}/images/index.html"     # path to the image list; like `digitalassets.lib.berkeley.edu/ds/missouri/images/index.html`
    images_html           = File.open(images_list) { |f| Nokogiri::HTML f }
    # all the mets files; e.g., `digitalassets.lib.berkeley.edu/ds/missouri/mets/*.xml`
    Dir["#{inst_dir}/mets/*.xml"].each do |in_xml|
      xml = File.open(in_xml) { |f| Nokogiri::XML f }
      # cycle through every `mets:xmlData` element with a filename
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
      #
      #     </mods:mods>
      #   </mets:xmlData>
      #  </mets:mdWrap>
      # </mets:dmdSec>

      xml.xpath('//mets:dmdSec[./mets:mdWrap/mets:xmlData/mods:mods/mods:identifier/@type="filename"]', NS).each do |node|
        # mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type='filename']
        dmdsec_id = node['ID']
        node.xpath("mets:mdWrap/mets:xmlData/mods:mods/mods:identifier[@type='filename']", NS).each do |filename|
          found_file = find_file html: images_html, filename: filename, inst_dir: inst
          found_file = 'NOT_FOUND' if found_file.to_s.strip.empty?
          csv << [inst, in_xml, dmdsec_id, filename, found_file]
          # puts sprintf("%-10s %-40s %-45s %s", inst, File.basename(in_xml), filename, found_file)
        end
      end
    end
  end
end
