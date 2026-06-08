# frozen_string_literal: true
module DS
  module Extractor
    class MarcTitleFormatter
      attr_accessor :datafield

      def format datafield
        datafield.xpath("subfield[@code='a' or @code='b']").map { |title|
          DS::Util.clean_string(title.text, terminator: '')
        }.join '; '
      end
    end
  end
end
