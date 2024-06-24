# frozen_string_literal: true

require_relative 'source/source_cache'
require_relative 'source/base_source'
require_relative 'source/marc_xml'
require_relative 'source/tei_xml'
require_relative 'source/ds_mets_xml'
require_relative 'source/ds_csv'

module DS
  # DS Source module classes encapsulates the loading of source files.
  # They are used by DS::Mapper classes and DS::Manifest id validator
  # classes.
  #
  # A primary function of the DS::Source classes is to manage
  # caching of source files, which may be expensive to load and parse; e.g.,
  # MARC XML or CSV files with a large number of records.
  module Source
  end
end
