require 'nokogiri'

module Recon
  module Type
    ##
    # Lookup subjects and named subjects for import CSV output
    #
    class AllSubjects < Recon::Type::Subjects

      extend DS::Util

      SET_NAME = :'all-subjects'

      METHOD_NAME = %i{ extract_all_subjects  }

    end
  end
end
