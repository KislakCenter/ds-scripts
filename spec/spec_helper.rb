require_relative '../lib/ds'
require 'nokogiri'
require 'csv'
require_relative 'support/helpers'

RSpec.configure do |c|
  c.fail_if_no_examples = true
  DS.env = 'test'
  DS.configure!
  # Do not run ReconData.update! for tests; recon CSVs are fixtures
  # Recon::ReconData.update!
  c.include Helpers
end

require_relative 'support/expectations'
require_relative 'support/extractor_examples'
require_relative 'support/recon_extractor_examples'
require_relative 'support/extractor_mapper_examples'
require_relative 'support/recon_builder_examples'
require_relative 'support/recon_type_examples'
require_relative 'support/source_cache_examples'
require_relative 'support/manifest_id_validator_examples'
require_relative 'support/manifest_validator_examples'
