#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
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

iiif_lookup           = Recon::URLLookup.new 'iiif_manifests'
ia_url_lookup         = Recon::URLLookup.new 'legacy_ia_urls'
manifest_generated_at = Time.now.strftime '%FT%T%z'

xml_files = ARGV.dup
CSV headers: true do |csv|
  csv << headers
  xml_files.each do |file|
    record                          = File.open(file) { |f| Nokogiri::XML f }
    holding_institution_as_recorded = DS::Extractor::DsMetsXml.extract_institution_name(record)
    holding_institution_shelfmark   = DS::Extractor::DsMetsXml.extract_shelfmark(record)

    row                             = {
      holding_institution_wikidata_qid:     DS::Institutions.find_qid(holding_institution_as_recorded),
      holding_institution_wikidata_label:   holding_institution_as_recorded,
      ds_id:                                nil,
      source_data_type:                     'ds-mets-xml',
      filename:                             File.basename(file),
      holding_institution_institutional_id: DS::Extractor::DsMetsXml.extract_shelfmark(record),
      institutional_id_location_in_source:  '//mods:mods/mods:identifier[@type="local"]/text()',
      call_number:                          holding_institution_shelfmark,
      link_to_institutional_record:         ia_url_lookup.find_url(
        holding_institution_as_recorded,
        holding_institution_shelfmark
      ),
      record_last_updated:                  record.xpath('/mets:mets/mets:metsHdr/@LASTMODDATE').text,
      title:                                DS::Extractor::DsMetsXml.extract_titles_as_recorded(record),
      iiif_manifest_url:                    iiif_lookup.find_url(
        holding_institution_as_recorded, holding_institution_shelfmark
      ),
      manifest_generated_at:                manifest_generated_at
    }
    csv << row
  end
end
