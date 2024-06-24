# frozen_string_literal: true

module Recon
  class DsMetsXmlEnumerator < SourceEnumerator

    # Iterates over each row in the CSV files and yields it to the provided block.
    # @yield [row] yields the parsed METS XML record
    def each &block
      process_xml files do |record|
        yield record
      end
    end
  end
end
