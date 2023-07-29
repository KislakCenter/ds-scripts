require_relative '../lib/ds'
require 'nokogiri'
require 'csv'

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

  def parse_csv csv_string
    CSV.parse csv_string, headers: true
  end

  def add_stubs obj, methods, return_val
    syms = *methods
    syms.each do |method|
      allow(obj).to receive(method).and_return return_val
    end
  end
end

RSpec.configure do |c|
  c.fail_if_no_examples = true

  c.include Helpers
end

require_relative './expections'