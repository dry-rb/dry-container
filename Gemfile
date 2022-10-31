# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "main"
gem "dry-core", github: "dry-rb/dry-core", branch: "main"

group :tools do
  gem "pry-byebug", platform: :mri
end
