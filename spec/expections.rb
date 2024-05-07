require 'rspec/expectations'

RSpec::Matchers.define :have_item_matching do |expected|
  match do |actual|
    actual.any? { |item| item =~ expected }
    failure_message_when_negated do |actual|
      "expected that #{actual} would have an item matching #{expected}"
    end
  end
end

RSpec::Matchers.define :be_a_date_time_string do
  match do |actual|
    DateTime.parse actual rescue false
    failure_message_when_negated do |actual|
      "expected that #{actual} would be a valid date-time string"
    end
  end
end

RSpec::Matchers.define :be_one_of do |expected|
  match do |actual|
    [expected].flatten.include? actual
    failure_message_when_negated do |actual|
      "expected that #{actual} would be one of #{expected.inspect}"
    end
  end
end

RSpec::Matchers.define :be_a_ds_id do
  match do |actual|
    expected.to_s =~ /^DS(NAME)?\d+$/
    failure_message_when_negated do |actual|
      "expected that #{actual} would match DS[0-9]+ or DSNAME[0-9]+"
    end
  end
end
