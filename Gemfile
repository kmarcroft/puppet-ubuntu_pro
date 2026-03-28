source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION'] || '~> 8.0'

gem 'puppet', puppet_version, require: false
gem 'rake', require: false

group :development do
  gem 'pdk', '~> 3.0', require: false
  gem 'puppet-lint', '>= 4.0', require: false
  gem 'puppet-lint-unquoted_string-check', require: false
  gem 'puppet-syntax', '>= 4.0', require: false
  gem 'rubocop', '>= 1.50', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'facterdb', require: false
  gem 'puppetlabs_spec_helper', '>= 7.0', require: false
  gem 'rspec-puppet', '>= 4.0', require: false
  gem 'rspec-puppet-facts', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end
