#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'optparse'

require_relative '../lib/ds'

##
# Script to scrape image count numbers from DS. Each collection on DS has a
# page that lists all its manusripts with the count of images available. See:
#
# https://digital-scriptorium.org/xtf3/search?rmode=digscript&smode=bid&bid=12&docsPerPage=30
#
# This script goes to each of those pages for the each collection that is
# dependent on DS for metadata and images. Some institutions have more than one
# collection id. These values are in DS::Constants::INSTITUTION_DS_IDS.
#
# Each manuscript is summarized in table with this structure:
#
#     <table cellspacing="0" cellpadding="0" border="0" align="center" width="620"
#       style="margin-left: 6px;">
#       <tr>
#         <td style="line-height:5px"></td>
#       </tr>
#       <tr>
#         <td valign="top">
#           <strong>1. </strong>
#         </td>
#         <td>
#           <a
#             href="http://digital-scriptorium.org/xtf3/search?rmode=digscript;smode=bid;bid=12;docsPerPage=1;startDoc=1;fullview=yes"
#             class="headLink1">San Francisco, State of California, Sutro Collection, Sutro Collection
#             Halliwell Phillips MS 01</a>
#         </td>
#       </tr>
#       <tr>
#         <td></td>
#         <td>
#           <span class="label_1">Description: </span> - 1 leaf;;Seal wanting, but with parchment
#           strips present - Mr. James Orchard Halliwell-Phillips; Adolph Sutro (1830-1898), mayor of
#           San Francisco; bought at Sotheby, Wilkinson &amp; Hodge auction, 1-4 July 1889 - William
#           E. Parker. "Items from the Halliwell-Phillipps Library in Sutro Branch, California State
#           Library." News Notes of California Libraries41.2 (1946): 249 </td>
#       </tr>
#       <tr>
#         <td></td>
#         <td>
#           <span class="label_1">Language: </span> LATIN    <span class="label_1">Country: </span>
#           England    <span class="label_1">Century: </span> 14th </td>
#       </tr>
#       <tr>
#         <td></td>
#         <td>
#           <span class="label_1">Number of Images Available: </span> 1 <br />
#         </td>
#       </tr>
#       <tr>
#         <td height="5" colspan="3"></td>
#       </tr>
#     </table>
#
# For each of these we extract the call number and the value of 'Number of
# Images Available'.


options = {
  out_file: 'ds-image-counts.csv'
}
parser = OptionParser.new do |opts|

  opts.banner = <<EOF
Usage: #{File.basename __FILE__} [options]

Scrape the DS website for data.

EOF
  out_help = "The output file [default '#{options[:out_file]}']"
  opts.on('-o file', '--outfile=FILE', out_help) do |path|
    options[:out_file] = path
  end

  image_help = 'Output image URLs (one line per image)'
  opts.on '-i', '--image-urls', image_help do
    options[:image_urls] = true
  end

  # # verbose
  # verb_help = "Print full error messages"
  # opts.on('-v', '--verbose', TrueClass, verb_help) do |verbose|
  #   options[:verbose] = verbose
  # end

  help_help = <<~EOF
    Prints this help

  EOF
  opts.on("-h", "--help", help_help) do
    puts opts
    exit
  end
end

parser.parse!

##
# Get the search results link, something like:
#
#    http://digital-scriptorium.org/xtf3/search?rmode=digscript;smode=bid;bid=37;docsPerPage=1;startDoc=1;fullview=yes
#
# This pulls up the page with the direct link and images
#
# @param [Nokogiri::HTML::Element] table table element for an MS listing
# @return [String] the +ms_link+ to the manuscript page
def link_to_ms_page table
  table.xpath('./descendant::td/a[@class="headLink1"]/@href').text
end

##
# @param [Nokogiri::HTML::Element] table table element for an MS listing
# @return [String] the manuscript's +callno+
def find_callno table
  # call number is the fifth value in the a.headLink1 text
  table.xpath('./descendant::td/a[@class="headLink1"]').text.split(/,/, 5).last
end

##
# @param [Nokogiri::HTML::Element] table table element for an MS listing
# @return [Integer] the listed number of images
def get_image_count table
  xpath = './descendant::span[starts-with(text(), "Number of Images")]/following-sibling::text()'
  table.xpath(xpath).text.to_i
end

##
# @param [Nokogiri::HTML::Document] ms_page the parsed HTML manuscript page
# @return [String]
def find_direct_link ms_page
  xpath = '//tr/td/span[contains(., "Direct Link")]/following-sibling::text()'
  ms_page.xpath(xpath).text
end

##
# @param [Nokogiri::HTML::Document] ms_page the parsed HTML manuscript page
# @return [Array<String>]
def find_image_urls ms_page
  xpath = '//p/a[contains(., "Download image")]/@href'
  ms_page.xpath(xpath).map &:text
end

output_file = options[:out_file]
SKIPS = %w{penn beneicke freelib}.freeze
headings = %w{ inst callno direct_link image_count }
headings << 'image_url' if options[:image_urls]

CSV.open(output_file, 'w') do |csv|
  csv << headings
  DS::INSTITUTION_DS_IDS.each do |id, inst|
    next if SKIPS.include? inst
    uri = "https://digital-scriptorium.org/xtf3/search?rmode=digscript&smode=bid&bid=#{id}&docsPerPage=2000"
    ms_list = URI.open(uri) { |f| Nokogiri::HTML f }
    ms_list.xpath('//td/table[descendant::td/a[@class="headLink1"]]').each do |table|

      images_available = get_image_count table
      link             = link_to_ms_page table
      callno           = find_callno table
      page             = URI.open(link) { |f| Nokogiri::HTML f }
      perma_link       = find_direct_link page
      if options[:image_urls]
        find_image_urls(page).each do |image_url|
          csv << [inst, callno.strip, perma_link.strip, images_available, image_url]
        end
      else
        csv << [inst, callno.strip, perma_link.strip, images_available]
      end
    end
  end
end

STDERR.puts "Wrote: #{output_file}"
