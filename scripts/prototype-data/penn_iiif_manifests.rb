#!/usr/bin/env ruby
##
# Locate Penn MS IIIF manifests from Penn MARC XML records. If there's an 856
# field that list the Colenda link ---
#
#     <marc:datafield ind1="4" ind2="1" tag="856">
#       <marc:subfield code="z">Digital facsimile for browsing (Colenda)</marc:subfield>
#       <marc:subfield code="u">https://colenda.library.upenn.edu/catalog/81431-p3pr7mv3j</marc:subfield>
#     </marc:datafield>
#
# then grab the URL and extract the ARK (e.g., +81431-p3pr7mv3j+). Use the
# ARK to build the manifest URL and confirm it's live. Output a CSV
# with columns for +mmsid+ and +iiif_manifest_url+.
#

require 'nokogiri'
require 'csv'
require "net/http"

CSV do |csv|
  csv << %w{mmsid iiif_manifest_url}
  ARGV.each do |file|
    xml = open(file.strip) { |f| Nokogiri::XML f }
    xml.remove_namespaces!
    mmsid = xml.xpath('//controlfield[@tag=001]').text.strip
    colenda_url = xml.xpath('//datafield[@tag=856 and contains(./subfield[@code="u"], "colenda")]/subfield[@code="u"]').text.strip
    ark         = colenda_url.split('/').last

    # https://colenda.library.upenn.edu/phalt/iiif/2/81431-p3pr7mv3j/manifest
    manifest_url = %Q{https://colenda.library.upenn.edu/phalt/iiif/2/#{ark}/manifest}

    url         = URI.parse manifest_url
    req         = Net::HTTP.new url.host, url.port
    req.use_ssl = true
    res         = req.request_head(url.path)
    next unless res.code == "200"
    csv << [mmsid, manifest_url]
  end
end
