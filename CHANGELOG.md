# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-03-28

### Fixed

- Pinned `json` and `json_pure` gems to `>= 2.7` to fix `JSON::Fragment` `NameError` on Ruby 3.2
- Replaced `puppet module build` with `build-puppet-module` in release workflow (command removed in Puppet 8)
- Added `puppet-modulebuilder` gem to Gemfile for CI builds

## [1.0.1] - 2026-03-28

### Fixed

- Removed `eyaml_lookup_key` backend from module-level `hiera.yaml` — eYAML belongs in the control-repo hierarchy, not the module data layer
- Fixed OS version check to use `$facts['os']['release']['full']` instead of `$facts['os']['release']['major']`, which is `undef` on Ubuntu
- Fixed all RuboCop violations: `frozen_string_literal` comments, hash alignment, modifier `if` style, RSpec context wording, message spies pattern, redundant cop disables
- Migrated `.rubocop.yml` from `require:` to `plugins:` for rubocop-performance and rubocop-rspec
- Excluded `.eyaml` files from puppet-syntax hieradata validation in Rakefile

### Changed

- Moved `data/common.eyaml` to `examples/common.eyaml` (example template, not active module data)
- Added `spec/classes/**/*.rb` and `spec/defines/**/*.rb` to `RSpec/DescribeClass` exclusions

## [1.0.0] - 2026-03-28

### Added

- Initial release of the `ubuntu_pro` module
- `pro_attach` custom type and provider for managing Ubuntu Pro subscription attachment
- `pro_service` custom type and provider for enabling/disabling individual Pro services (esm-infra, esm-apps, livepatch, etc.)
- `ubuntu_pro_status` custom fact reporting attachment state and active services (never exposes the token)
- Full eYAML integration for secure token storage — token never touches disk, process table, logs, or reports on managed nodes
- Token passed to `pro attach` exclusively via stdin
- Sensitive type enforcement with redacted `is_to_s`/`should_to_s` overrides
- Error output scrubbing to prevent accidental token leakage
- Puppet 8.x / OpenVox 8.x compatibility (Ruby 3.2+)
- Ubuntu 22.04 (Jammy) and 24.04 (Noble) support with forward-compatible OS version check
- PDK-compatible module structure
- GitHub Actions CI pipeline: lint, syntax, RuboCop, unit tests (Puppet 8 on Ruby 3.2/3.3), security checks
- GitHub Actions release workflow with artifact upload
- Pre-commit hooks for local development (puppet-lint, syntax, RuboCop, hardcoded token detection)
- eYAML example template for secure token storage
- RSpec unit tests for the main class, custom type, and provider

[1.0.2]: https://github.com/kmarcroft/puppet-ubuntu_pro/releases/tag/v1.0.2
[1.0.1]: https://github.com/kmarcroft/puppet-ubuntu_pro/releases/tag/v1.0.1
[1.0.0]: https://github.com/kmarcroft/puppet-ubuntu_pro/releases/tag/v1.0.0
