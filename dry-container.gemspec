# frozen_string_literal: true

# this file is synced from dry-rb/template-gem project

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dry/container/version"

Gem::Specification.new do |spec|
  spec.name          = "dry-container"
  spec.authors       = ["Andy Holland"]
  spec.email         = ["andyholland1991@aol.com"]
  spec.license       = "MIT"
  spec.version       = Dry::Container::VERSION.dup

  spec.summary       = "A simple, configurable object container implemented in Ruby"
  spec.description   = spec.summary
  spec.homepage      = "https://dry-rb.org/gems/dry-container"
  spec.files         = Dir["CHANGELOG.md", "LICENSE", "README.md", "dry-container.gemspec", "lib/**/*"]
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["changelog_uri"]     = "https://github.com/dry-rb/dry-container/blob/master/CHANGELOG.md"
  spec.metadata["source_code_uri"]   = "https://github.com/dry-rb/dry-container"
  spec.metadata["bug_tracker_uri"]   = "https://github.com/dry-rb/dry-container/issues"

  spec.required_ruby_version = ">= 2.7.0"

  # to update dependencies edit project.yml
  spec.add_runtime_dependency "concurrent-ruby", "~> 1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
