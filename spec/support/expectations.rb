require 'rspec/expectations'

RSpec::Matchers.define :have_item_matching do |expected|
  failure_message_when_negated do |actual|
    "expected that #{actual} would have an item matching #{expected}"
  end
  match do |actual|
    actual.any? { |item| item =~ expected }
  end
end


RSpec::Matchers.define :be_some_kind_of_date_time do
  failure_message_when_negated do |actual|
    "expected that #{actual} would be a date-time string or date or time instance"
  end
  match do |actual|
    expect(actual).to be_a_date_time_string.or(be_a Date).or(be_a Time)
  end
end

RSpec::Matchers.define :be_a_date_time_string do
  failure_message_when_negated do |actual|
    "expected that #{actual} would be a valid date-time string"
  end
  match do |actual|
    DateTime.parse(actual) rescue false
  end
end

RSpec::Matchers.define :be_one_of do |expected|
  unless expected.respond_to? :include?
    raise ":be_one_of expectation must implement #include? got '#{expected.inspect}'"
  end
  failure_message_when_negated do |actual|
    "expected that #{actual} would be one of #{expected.inspect}"
  end
  match do |actual|
    expected.flatten.include? actual
  end
end

RSpec::Matchers.define :be_a_ds_id do
  failure_message_when_negated do |actual|
    "expected that #{actual} would match DS[0-9]+ or DSNAME[0-9]+"
  end
  match do |actual|
    actual.to_s =~ /^DS(NAME)?\d+$/
  end
end

RSpec::Matchers.define :have_columns do |headings|
  failure_message_when_negated do |actual|
    <<~EOF
      expected that each row of #{actual} would have #{num_columns} columns
      missing headings: #{missing}"
EOF
  end
  match do |actual|
    (headings - actual.keys).blank?
  end
end

RSpec::Matchers.define :have_hash_value do |key|
  failure_message_when_negated do |actual|
    "expected a value for #{key.inspect} that each row of #{actual}"
  end
  match do |actual|
    actual[key].present?
  end
end
