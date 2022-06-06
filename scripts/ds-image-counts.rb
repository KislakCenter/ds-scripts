#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'

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

output_file = 'ds-image-counts.csv'

CSV.open(output_file, 'w') do |csv|
  csv << %w{ inst callno count }
  DS::INSTITUTION_DS_IDS.each do |id, inst|
    uri = "https://digital-scriptorium.org/xtf3/search?rmode=digscript&smode=bid&bid=#{id}&docsPerPage=2000"
    ms_list = URI.open(uri) { |f| Nokogiri::HTML f }
    ms_list.xpath('//td/table[descendant::td/a[@class="headLink1"]]').each do |table|
      # call number is the fifth value in the a.headLink1 text
      callno           = table.xpath('./descendant::td/a[@class="headLink1"]').text.split(/,/, 5).last
      number_available = table.xpath('./descendant::span[starts-with(text(), "Number of Images")]/following-sibling::text()')
      csv << [inst, callno.strip, number_available]
    end
  end
end

STDERR.puts "Wrote: #{output_file}"
