# frozen_string_literal: true

module DS
  module Extractor
    class Name < BaseTerm
      attr_accessor :role
      attr_accessor :vernacular
      attr_accessor :ref

      def initialize as_recorded:, role: nil, vernacular: nil, ref: nil
        @role        = role
        @vernacular  = vernacular
        @ref         = ref
        super(as_recorded: as_recorded)
      end

      def to_a
        [as_recorded, role, vernacular, ref]
      end
    end
  end
end
