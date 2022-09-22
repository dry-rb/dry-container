# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

# gem "dry-configurable"
gem "dry-configurable", github: "dry-rb/dry-configurable", branch: "write-settings-in-configure-only"
gem "dry-core", github: "dry-rb/dry-core"

group :tools do
  gem "pry-byebug", platform: :mri
end
