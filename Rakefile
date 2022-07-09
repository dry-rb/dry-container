#!/usr/bin/env rake
# frozen_string_literal: true

require "rspec/core/rake_task"

task default: :spec

desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec)

desc "Run specs with dry/configurable loaded"
task "spec:configurable" do
  ENV["DRY_CONFIGURABLE"] = "true"
  Rake::Task["spec"].invoke
end
