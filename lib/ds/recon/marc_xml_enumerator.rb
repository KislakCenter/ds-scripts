# frozen_string_literal: true

module Recon
  class MarcXmlEnumerator < SourceEnumerator

    def each &block
      process_xml files, remove_namespaces: true do |xml|
        xml.xpath('//record').each do |record|
          yield record
        end
      end
    end

  end
end
