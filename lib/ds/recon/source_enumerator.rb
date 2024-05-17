# frozen_string_literal: true

module Recon
  class SourceEnumerator
    include DS::Util
    include Enumerable

    attr_accessor :files
    # Initialize the SourceEnumerator with the given files.
    # @param [Array] files an array of source file paths
    def initialize files
      @files = *files
    end

    ##
    # @yield record a record of the SourceEnumerator's type (MARC XML, CSV::Row, etc.)
    def each &block
      raise NotImplementedError
    end
  end
end
