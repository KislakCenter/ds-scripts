# frozen_string_literal: true


require_relative 'manifest/constants'
require_relative 'manifest/entry'
require_relative 'manifest/manifest'
require_relative 'manifest/manifest_validator'

module DS
  ##
  # DS::Manifest comprises classes and a module (DS::Manifest::Constants)
  # for encapsulating and validating a DS delivery manifest CSV.
  #
  # The manifest CSV provides all information needed to ingest a set of
  # source records. This information is detailed in {DS::Manifest::Manifest}.
  #
  module Manifest
  end
end