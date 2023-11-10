# frozen_string_literal: true

module DS
  module Util
    class XMLCache
      attr_reader :data
      attr_accessor :seconds

      XMLData = Struct.new 'XMLData', :path, :xml, :time do |d|
        def age
          Time.new - time
        end
      end

      def initialize seconds: 5
        @seconds = seconds
        @data = []
      end

      def add path:, xml:
        @data << XMLData.new(path, xml, Time.now)
        cleanup
        @data.last
      end

      def has_xml? path
        find path: path
      end

      def get path
        current = find path: path
        current.time = Time.now if current
        current
      end

      def find path:
        data.find { |x| x.path == path }
      end

      def cleanup
        @data.reject! { |d| d.age > seconds }
      end
    end
  end
end