# frozen_string_literal: true

module Recon
  class DsMetsXmlEnumerator < SourceEnumerator

    def each &block
      process_xml files do |record|
        yield record
      end
    end
  end
end
