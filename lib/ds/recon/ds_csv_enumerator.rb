# frozen_string_literal: true

module Recon
  class DsCsvEnumerator < SourceEnumerator

    def each &block
      files.each do |file|
        CSV.foreach file, headers: true do |row|
          yield row
        end
      end
    end
  end
end
