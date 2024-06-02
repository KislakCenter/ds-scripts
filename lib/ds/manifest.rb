# frozen_string_literal: true


require_relative 'manifest/constants'
require_relative 'manifest/entry'
require_relative 'manifest/manifest'
require_relative 'manifest/base_id_validator'
require_relative 'manifest/simple_xml_id_validator'
require_relative 'manifest/ds_csv_id_validator'
require_relative 'manifest/marc_id_validator'
require_relative 'manifest/manifest_validator'

module DS
  ##
  # {DS::Manifest} comprises classes and a module (DS::Manifest::Constants)
  # for encapsulating and validating a DS delivery manifest CSV.
  #
  # The manifest CSV provides all information needed to ingest a set of
  # source records. This information is detailed in
  # {DS::Manifest::Manifest}.
  #
  # The {DS::Manifest::ManifestValidator} validates
  # that the Manifest is completed and well-formed, and that all records
  # can be found the specified source diretory.
  #
  # The valid {DS::Manifest::Manifest} is used by {DS::Converter::Converter}
  # to orchestrate mapping of source record data for the creation of
  # the DS import CSV.
  module Manifest
  end
end
