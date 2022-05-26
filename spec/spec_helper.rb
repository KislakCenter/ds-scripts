require_relative '../lib/ds'

module Helpers
  def fixture_path relpath
    path = File.join __dir__, 'fixtures', relpath
    return path if File.exist? path

    raise "Unable to find fixture: #{relpath} in #{__dir__}"
  end
end

RSpec.configure do |c|
  c.fail_if_no_examples = true

  c.include Helpers
end
