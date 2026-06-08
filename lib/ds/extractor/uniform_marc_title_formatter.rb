# frozen_string_literal: true
module DS
  module Extractor
    class UniformMarcTitleFormatter
      attr_accessor :datafield

      def format datafield
        arr = datafield.xpath("subfield[@code='a' or @code='p']").map { |title|
          DS::Util.clean_string(title.text, terminator: '')
        }
        first = arr.shift
        arr.empty? ? first : "#{first}: #{arr.join ' '}"
      end
    end
  end
end
