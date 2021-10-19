require_relative './ds/constants'
require_relative './ds/ds10'
require_relative './ds/openn_tei'
require_relative './ds/marc_xml'

module DS
  include DS::Constants

  module ClassMethods
    def clean_string string, terminator: nil
      # handle DS legacy superscript encoding, whitespace, duplicate '.', and ensure a
      # terminator is present if added
      normal = string.to_s.gsub(%r{#\^([^#]+)#}, '(\1)').gsub(%r{\s+}, ' ').strip.gsub(%r{\.\.+}, '.')
      terminator.nil? ? normal : "#{normal.sub(%r{[.;,!?]+$}, '').strip}."
    end
  end

  self.extend ClassMethods
end