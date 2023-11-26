#!/usr/bin/env ruby
# frozen_string_literal: true
require 'nokogiri'

require_relative '../lib/ds'

headers = %i{
  holding_institution_wikidata_qid
  holding_institution_wikidata_label
  ds_id
  source_data_type
  filename
  holding_institution_institutional_id
  institutional_id_location_in_source
  call_number
  link_to_institutional_record
  record_last_updated
  title
  iiif_manifest_url
  manifest_generated_at
}

holding_institution_wikidata_qid = 'Q3087288'
holding_institution_wikidata_label = 'Free Library of Philadelphia'
ds_id = nil
source_data_type = 'tei-xml'
manifest_generated_at = Time.now
URL_FORMAT = "https://openn.library.upenn.edu/Data/0023/html/%s.html"
MODIFICATION_DATES = File.readlines(File.join __dir__, 'flp_modification_dates.txt').inject({}) { |hash, row|
  time, folder = row.split
  hash[folder] = Date.parse time
  hash
}

def last_modified_date folder
  return '' unless MODIFICATION_DATES[folder]
  MODIFICATION_DATES[folder].strftime "%Y-%m-%d"
end

tei_files = ARGV.dup

CSV headers: true do |csv|
  csv << headers
  tei_files.each do |xml_file|
    xml                                  = File.open(xml_file) { |f| Nokogiri::XML f }
    xml.remove_namespaces!
    base                                 = File.basename xml_file, '_TEI.xml'

    filename                             = File.basename xml_file
    holding_institution_institutional_id = DS::OPennTEI.extract_holding_institution_id_nummber xml
    institutional_id_location_in_source  = '/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno'
    call_number                          = DS::OPennTEI.extract_shelfmark xml
    link_to_institutional_record         = sprintf URL_FORMAT, base
    record_last_updated                  = last_modified_date base
    title                                = (DS::OPennTEI.extract_title_as_recorded(xml) || []).first
    iiif_manifest_url                    = nil
    manifest_generated_at                = Time.now.strftime '%Y-%m-%dT%H:%M:%S%z'

    # in case there's no institutional ID, use the call number
    institutional_id = call_number

    data = {
      holding_institution_wikidata_qid:     holding_institution_wikidata_qid,
      holding_institution_wikidata_label:   holding_institution_wikidata_label,
      ds_id:                                ds_id,
      source_data_type:                     source_data_type,
      filename:                             filename,
      holding_institution_institutional_id: institutional_id,
      institutional_id_location_in_source:  institutional_id_location_in_source,
      call_number:                          call_number,
      link_to_institutional_record:         link_to_institutional_record,
      record_last_updated:                  record_last_updated,
      title:                                title,
      iiif_manifest_url:                    iiif_manifest_url,
      manifest_generated_at:                manifest_generated_at
    }
    csv << data
  end
end