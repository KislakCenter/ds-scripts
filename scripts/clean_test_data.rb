#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'

MAX = 16302

input_csv = ARGV.shift

output_csv = "test-#{File.basename input_csv}"

TERM_LISTS = {
  corporate_names: 'terms/corporate_names.txt',
  personal_names:  'terms/personal_names.txt',
  languages:       'terms/languages.txt',
  places:          'terms/places.txt',
  titles:          'terms/titles.txt',
  terms:           'terms/terms.txt',
  materials:       'terms/materials.txt'
}

HEADERS_TO_TERM_TYPES = {
  'holding_institution_ds_qid' => :corporate_names,
  'production_place_ds_qid'    => :places,
  'standard_title_ds_qid'      => :titles,
  'genre_ds_qid'               => :terms,
  'subject_ds_qid'             => :terms,
  'author_ds_qid'              => :personal_names,
  'artist_ds_qid'              => :personal_names,
  'scribe_ds_qid'              => :personal_names,
  'associated_agent_ds_qid'    => :personal_names,
  'former_owner_ds_qid'        => :personal_names,
  'language_ds_qid'            => :languages,
  'material_ds_qid'            => :materials,
}.freeze

class Terms
  def initialize
    @hash = Hash.new
    @randoms = Hash.new
    @used = Hash.new
  end

  def add_terms term_type, terms
    @hash[term_type] = terms
  end

  def all_terms
    @hash
  end

  def random_term term_type
    @hash[term_type].sample
  end

  # @param qid [String] the QID to get
  # @param term_type [Symbol] one of :corporate_names, :personal_names, :languages, :places, :titles, :terms, :materials
  # @return [String] a the qid previously used for this qid, or a random QID for the +term_type+
  def get_qid term_type, qid
    @used[qid] ||= random_term term_type
  end
end

ALL_TERMS = TERM_LISTS.reduce(Terms.new) { |terms, key_value|
  term_type, txt = key_value
  terms.add_terms term_type, open(File.join(__dir__, txt), 'r').readlines.map(&:strip)
  terms
}


# Return a QID that is less than MAX, following these rules:
#
# - If +qid+ is already less than MAX, return it.
# - If +qid+ is greater than MAX, return a random QID for the
#   +term_type+.
# - Otherwise, return an empty string.
#
# @param term_type [Symbol] one of :corporate_names, :personal_names, :languages, :places, :titles, :terms, :materials
# @param qid [String] the QID to normalize
# @return [String] a value as described above
def normalize_qid(term_type, qid)
  return '' unless qid =~ /Q(\d+)/
  return qid if $1.to_i <= MAX

  ALL_TERMS.get_qid term_type, qid
end

def clean_qids term_type, qid_string
  qid_string.split('|', -1).map { |pipes|
    pipes.split(';', -1).map { |qid|
      normalize_qid term_type, qid
    }.join ';'
  }.join '|'
end

CSV.open output_csv, 'wb', headers: true do |csv|
  CSV.new(File.open(input_csv, 'r'), headers: true).each_with_index do |row, index|
    csv << row.headers if index == 0
    row_hash = row.to_h
    row_hash.each do |column, value|
      next unless column =~ /_ds_qid$/ # skip non qid columns
      next unless value =~ /Q\d+/ # skip when there are no QIDs

      term_type        = HEADERS_TO_TERM_TYPES[column]
      row_hash[column] = clean_qids term_type, value
    end
    csv << row_hash
  end
end

puts "Wrote: #{output_csv}"
