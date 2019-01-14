source 'https://rubygems.org'

gemspec

gem 'dry-configurable', git: 'https://github.com/dry-rb/dry-configurable'

group :test do
  platforms :mri do
    gem 'codeclimate-test-reporter', require: false
    gem 'simplecov', require: false
  end
end

group :tools do
  gem 'rubocop'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '3.0.6'
end
