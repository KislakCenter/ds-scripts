# frozen_string_literal: true

module DS
  module Extractor
    class Name
      attr_accessor :as_recorded
      attr_accessor :role
      attr_accessor :vernacular
      attr_accessor :ref

      def initialize as_recorded: nil, role: nil, vernacular: nil, ref: nil
        @as_recorded = as_recorded
        @role        = role
        @vernacular  = vernacular
        @ref         = ref
      end

      def to_a
        [as_recorded, role, vernacular, ref]
      end
    end
  end
end
