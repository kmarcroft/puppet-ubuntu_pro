require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.relative = true
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'vendor/**/*.pp', 'pkg/**/*.pp']

PuppetSyntax.check_hiera_keys = true
PuppetSyntax.exclude_paths = ['spec/fixtures/**/*', 'pkg/**/*', 'vendor/**/*']

desc 'Validate manifests, templates, and ruby files'
task validate: %i[lint syntax spec]

desc 'Run all checks (lint, syntax, spec, rubocop)'
task checks: %i[lint syntax spec rubocop]

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['--display-cop-names']
  end
rescue LoadError
  desc 'rubocop is not available'
  task :rubocop do
    warn 'rubocop is not available; install it with: gem install rubocop'
  end
end
