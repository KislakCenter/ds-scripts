# frozen_string_literal: true

module Recon
  class Iterator
    include Enumerable

    attr_accessor :files
    def initialize *files
      @files = files
    end

    ##
    # @yield record a record of the Iterator's type (MARC XML, CSV::Row, etc.)
    def each &block
      raise NotImplementedError
    end
  end
end
