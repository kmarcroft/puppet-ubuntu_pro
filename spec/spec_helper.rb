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

include RspecPuppetFacts # rubocop:disable Style/MixinUsage

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version
}

default_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load_file(default_facts_path, permitted_classes: [Symbol]))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load_file(default_module_facts_path, permitted_classes: [Symbol]))
end

RSpec.configure do |c|
  c.default_facts = default_facts
  c.before do
    # Ensure we don't accidentally connect to any services
    Puppet::Util::Log.level = :warning
  end
end
