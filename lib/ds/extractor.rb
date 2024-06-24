# frozen_string_literal: true

require_relative 'extractor/base_term'
require_relative 'extractor/genre'
require_relative 'extractor/material'
require_relative 'extractor/name'
require_relative 'extractor/place'
require_relative 'extractor/subject'
require_relative 'extractor/title'
require_relative 'extractor/language'
require_relative 'extractor/base_record_locator'
require_relative 'extractor/xml_record_locator'
require_relative 'extractor/csv_record_locator'

module DS
  # Module for DS Extractor classes, which are responsible for extracting
  # import CSV rows from source records.
  #
  # Extractors are used by {DS::Mapper::BaseMapper} instances to extract
  # data from a source records and by {Recon::ReconBuilder} instances
  # to extract data from DS data sources for recon CSVs.
  module Extractor
  end
end
