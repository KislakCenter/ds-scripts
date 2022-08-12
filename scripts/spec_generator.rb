#!/usr/bin/env ruby

require 'erb'

template = ERB.new <<EOF
      it %q{removes a space before trailing punctuation ('car <%= value %>"' => 'car"')} do
        expect(DS.terminate %q{car <%= value %>"}, terminator: '').to eq 'car"'
      end

EOF

values = '.,;:?!'.split //

values.each do |value|
  puts template.result binding
end