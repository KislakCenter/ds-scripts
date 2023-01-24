#!/usr/bin/env ruby

##
# The Princeton MARC data comes in three files:
#
# - IslamicGarrettBIB1.xml
# - IslamicGarrettBIB2.xml
# - IslamicGarrettHoldingsandMMSID.xml
#
# We don't know the relationship between BIB1 and BIB2. However, the MMSID file
# contains the mapping from the OPAC ID number to the call numbers.
#
# To add Princeton MSS update the file
# `data/prototype-data/princeton/IslamicGarrettBIB1-trim.xml` with a new
# records and then run the following scripts, pointing to the corresponding
# source file.
#
#   bundle exec ruby scripts/princeton_update_bib2.rb \
#       ~/tmp/Islamic\ MSS\ Metadata/IslamicGarrettBIB2.xml
#
#   bundle exec ruby scripts/princeton_update_holdings.rb \
#       ~/tmp/Islamic\ MSS\ Metadata/IslamicGarrettHoldingsandMMSID.xml
#
require 'nokogiri'

bib2_path = ARGV.shift
abort "Please give the path to the Bib2 file" if bib2_path.nil?
abort "Can't locate bib2 file: #{bib2_path}" unless File.exist? bib2_path

# import bib1 trim
bib1_path   = File.expand_path '../../data/prototype-data/princeton/IslamicGarrettBIB1-trim.xml', __FILE__
bib1_trim   = Nokogiri::XML open(bib1_path), nil, "UTF-8"
output_path = File.expand_path '../../data/prototype-data/princeton/IslamicGarrettBIB2-trim.xml', __FILE__
bib2        = Nokogiri::XML File.read bib2_path

# use nokogiri to extract 001 ID
ids               = bib1_trim.xpath("/collection/record/controlfield[@tag=001]").map(&:text)
query             = ids.map { |id| "./text() = '#{id}'" }.join " or " # or query for every ID
matching_elements = bib2.xpath "//record[controlfield[@tag = '001' and (#{query})]]"

output_doc = %Q{<collection></collection>}
doc    = Nokogiri::XML.parse output_doc, nil, "UTF-8"
source = doc.root

matching_elements.each do |e|
  source << e
end

# output the Trimmed Bib2 file
File.open(output_path, 'w') { |f| f.puts doc.to_xml }

STDERR.puts "Wrote: #{output_path}"