#!/usr/bin/env ruby

require 'csv'

require_relative '../lib/ds'

NS = {
  mods: 'http://www.loc.gov/mods/v3',
  mets: 'http://www.loc.gov/METS/',
}

HEADERS = %i{
  file
  shelfmark
  ms_note_types
  ms_phys_desc
  number_of_parts
  part_note_types
  part_phys_desc
  number_of_texts
  text_note_types
  number_of_pages
  page_notes
}

def count_notes nodes, look: false, phys_desc: false
  note_types = { untyped: 0 }
  path = './descendant::mods:mods/mods:note/@type'
  path = './mods:note/@type' if phys_desc
  nodes.map { |node|
    notes = node.xpath path, NS
    notes.each do |note|
      note_type = note.text
      (note_types[note_type] ||= 0)
      note_types[note_type] += 1
    end
    untyped_path = './descendant::mods:mods/mods:note[not(@type)]'
    untyped_path = './mods:note[not(@type)]' if phys_desc
    note_types[:untyped] += node.xpath(untyped_path, NS).size
  }
  note_types.reject{ |k,v| v == 0 }.map { |k, v| "#{k}:#{v}" }.join ', '
end


CSV do |csv|
  csv << HEADERS
  ARGF.each do |in_xml|
    source_file = in_xml.chomp
    xml         = File.open(source_file) { |f| Nokogiri::XML(f) }

    ms         = DS::Extractor::DsMetsXml.find_ms xml
    shelfmark  = DS::Extractor::DsMetsXml.extract_shelfmark xml
    ms_note_types = count_notes [ms].flatten
    ms_pds = ms.xpath 'descendant::mods:physicalDescription'
    ms_phys_desc = count_notes ms_pds, phys_desc: true
    parts = DS::Extractor::DsMetsXml.find_parts xml
    number_of_parts = parts.size
    part_note_types = count_notes parts
    part_pds = parts.flat_map { |p| p.xpath('descendant::mods:physicalDescription') }
    part_phys_desc = count_notes part_pds, phys_desc: true
    texts = DS::Extractor::DsMetsXml.find_texts xml
    number_of_texts = texts.size
    text_note_types = count_notes texts
    pages = DS::Extractor::DsMetsXml.find_pages xml
    number_of_pages = pages.size
    page_notes = count_notes pages
    csv << [
      source_file, shelfmark, ms_note_types, ms_phys_desc,
      number_of_parts, part_note_types, part_phys_desc,
      number_of_texts, text_note_types,
      number_of_pages, page_notes
    ]
  end
end
