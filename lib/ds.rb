require_relative './ds/constants'
require_relative './ds/ds10'
require_relative './ds/openn_tei'
require_relative './ds/marc_xml'

module DS
  include DS::Constants

  module ClassMethods
    def clean_string string, terminator: nil
      # handle DS legacy superscript encoding, whitespace, duplicate '.', and ensure a
      normal = string.to_s.gsub(%r{#\^([^#]+)#}, '(\1)').gsub(%r{\s+}, ' ').strip.gsub(%r{\.\.+}, '.').delete '[]'
      # terminator is added if present after any removing trailing whitespace and punctuation
      terminator.nil? ? normal : "#{normal.sub(%r{[[:punct:][:space:]]+$}, '').strip}."
    end

    def find_qid inst_alias
      # try without changes; and then normalize
      DS::INSTITUTION_NAMES_TO_QID[inst_alias] or
        DS::INSTITUTION_NAMES_TO_QID[inst_alias.to_s.strip] or
        DS::INSTITUTION_NAMES_TO_QID[inst_alias.to_s.strip.downcase]
    end

    def preferred_inst_name inst_alias
      url = find_qid inst_alias
      return unless url =~ %r{Q\d+$}
      qid = Regexp.last_match[0]
      DS::QID_TO_INSTITUTION_NAMES[qid].first
    end

    def transform_date_to_century date
      return if date.nil?
      century = []
      date.split('-').each do |d|
        if d.length <= 3
          century << (d[0].to_i + 1).to_s
        else
          century << (d[0..1].to_i + 1).to_s
        end
      end
      century.uniq.join '-'
    end

    def timestamp
      DateTime.now.iso8601.to_s
    end
  end

  self.extend ClassMethods
end