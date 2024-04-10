# frozen_string_literal: true

module DS
  module Extractor
    ##
    # BaseTerm is a composite object for multi-value term sets, like
    # subjects, names, and titles, that may have complex
    # representation in source records. For example, names in MARC
    # records, have as recorded values, but also have roles (like
    # author, scribe, etc.) and may also have vernacular script
    # versions.
    #
    # The BaseTerm has the +:as_recorded+ attribute, which all term
    # types must have.
    #
    # The BaseTerm also has a '#to_a' method which returns the
    # +as_recorded+ value:
    #
    #   term = BaseTerm.new as_recorded: 'Some value'
    #   term.to_a => ['Some value']
    #
    # Implementing classes should add other relevant attributes
    # (+:vernacular+, +:role+, etc.) and implement +#to_a+.
    #
    # NB: BaseTerm instances are used by extractors and the +#to_a+
    # by the ReconBuilder, which assumes values returned are in the
    # order of the first columns of each corresponding recon CSV. For
    # example, the languages.csv has these columns:
    #
    #   language_as_recorded,language_code,authorized_label,structured_value
    #   Arabic,ara,Arabic,Q13955
    #
    # The +authorized_label+ and +structured_value+ columns are added
    # by the ReconBuilder which expects +term.to_a+ an array
    # containing the first two column values:
    #
    #     term.to_a  # => ['Arabic', 'ara']
    #
    # @todo: This might be better handle by a +#to_h+ method with
    #     keys that map to the recon CSV columns. However, for this
    #     to work, the recon CSVs columns would need to be changed
    #     from names like 'language_as_recorded' to 'as_recorded' and
    #     so on. The change would need to made throughout the software
    #     and the change approved by thd DS Project Manager.
    class BaseTerm
      attr_accessor :as_recorded

      def initialize as_recorded:
        @as_recorded = as_recorded
      end

      def to_a
        [as_recorded]
      end
    end
  end
end
