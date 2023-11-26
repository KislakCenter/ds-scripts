# frozen_string_literal: true
require 'nokogiri'
require 'csv'

headers = %w{
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


data = []
CSV headers: true do |csv|
  csv << headers
  ARGV.each do |xml_file|
    record = File.open(source_file) { |f| Nokogiri::XML(f) }
    record.remove_namespaces!

    filename = File.basename xml_file
    bibid = record.xpath
  end
end