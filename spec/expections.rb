require 'rspec/expectations'

RSpec::Matchers.define :have_item_matching do |expected|
  match do |actual|
    actual.any? { |item| item =~ expected }
    failure_message_when_negated do |actual|
      "expected that #{actual} would have an item matching #{expected}"
    end
  end
end
