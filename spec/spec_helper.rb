require_relative '../lib/ds'
require 'nokogiri'

module Helpers
  def fixture_path relpath
    path = File.join __dir__, 'fixtures', relpath
    return path if File.exist? path

    raise "Unable to find fixture: #{relpath} in #{__dir__}"
  end

  def marc_record xml_string
    xml = Nokogiri::XML xml_string
    xml.remove_namespaces!
    xml.xpath('record')[0]
  end

  def openn_tei xml_string
    xml = Nokogiri::XML xml_string
    xml.remove_namespaces!
    xml
  end
end

RSpec.configure do |c|
  c.fail_if_no_examples = true

  c.include Helpers
end

require_relative './expections'