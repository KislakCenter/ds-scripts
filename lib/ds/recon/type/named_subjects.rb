require 'nokogiri'

module Recon
  module Type
    ##
    # Extract named subjects for reconciliation CSV output.
    #
    # Return a two-dimensional array, each row is a term; and each row has
    # two columns: subject and authority number.
    #
    class NamedSubjects < Recon::Type::Subjects

      extend DS::Util
      SET_NAME = :'named-subjects'

      METHOD_NAME = %i{ extract_named_subjects }

    end
  end
end
