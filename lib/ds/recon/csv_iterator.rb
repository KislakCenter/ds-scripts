# frozen_string_literal: true

module Recon
  class CSVIterator < Iterator

    def each &block
      files.each do |file|
        CSV.foreach file, headers: true do |row|
          yield row
        end
      end
    end
  end
end
