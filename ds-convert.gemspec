# frozen_string_literal: true

require_relative "lib/ds/version"

Gem::Specification.new do |spec|
  spec.name = "ds-convert"
  spec.version = DS::VERSION
  spec.authors = ["Doug Emery"]
  spec.email = ["emeryr@upenn.edu"]

  spec.summary = "ETL scripts for managing Digital Scriptorium member data"
  spec.description = <<~DESC
    Scripts for convert Digital Scriptorium member data to the DS import spreadsheet format and for extracting values for authority file reconciliation.
  DESC
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = ">= 3.3"

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'
  spec.metadata["homepage_uri"] = 'https://github.com/DigitalScriptorium/ds-convert'
  spec.metadata["source_code_uri"] = 'https://github.com/DigitalScriptorium/ds-convert'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[
        bin/ Gemfile .gitignore .rspec spec/ .gitlab-ci.yml .
        gitleaks.toml .tool-versions .ruby-version .rubocop.yml
        data scripts docs config/environments
        ])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '~> 8.0.2'
  spec.add_dependency 'colorize', '~> 1.1.0'
  spec.add_dependency 'config', '~> 3'
  spec.add_dependency 'csv', '~> 3.3.5'
  spec.add_dependency 'git', '~> 1.11.0'
  spec.add_dependency 'marc', '~> 1.1.1'
  spec.add_dependency 'nokogiri', '~> 1.15.3'
  spec.add_dependency 'thor', '~> 1.2.1'

end
