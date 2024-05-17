# frozen_string_literal: true

module Recon
  class DsCsvEnumerator < SourceEnumerator

    # Iterates over each row in the CSV files and yields it to the provided block.
    # @yield [row] yields each row in the CSV file
    def each &block
      files.each do |file|
        CSV.foreach file, headers: true do |row|
          yield row
        end
      end
    end
  end
end
