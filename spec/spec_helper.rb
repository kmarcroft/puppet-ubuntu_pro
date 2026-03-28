# frozen_string_literal: true

# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

begin
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
    formatter SimpleCov::Formatter::MultiFormatter.new(
      [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::Console
      ]
    )
  end
rescue LoadError
  # simplecov not available
end

include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version
}

[File.join(__dir__, 'default_facts.yml'), File.join(__dir__, 'default_module_facts.yml')].each do |path|
  default_facts.merge!(YAML.safe_load_file(path, permitted_classes: [Symbol])) if File.exist?(path)
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.before do
    # Ensure we don't accidentally connect to any services
    Puppet::Util::Log.level = :warning
  end
end
