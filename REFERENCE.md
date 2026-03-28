# REFERENCE.md - Type and Provider Reference

## Resource Types

### pro_attach

Manages Ubuntu Pro subscription attachment.

#### Properties

- **ensure** — Whether the system should be `attached` or `detached`. Default: `attached`.

#### Parameters

- **name** — An arbitrary name for this resource instance. (namevar)
- **token** — The Ubuntu Pro subscription token. Accepted as `Sensitive[String]`. The token is:
  - Wrapped in `Sensitive` internally (auto-munged if raw string provided)
  - Never logged (all `*_to_s` methods return `[redacted]`)
  - Passed to `pro attach` via stdin only
  - Scrubbed from error messages on failure

### pro_service

Manages individual Ubuntu Pro services.

#### Properties

- **ensure** — Whether the service should be `enabled` or `disabled`. Default: `enabled`.

#### Parameters

- **name** — The Ubuntu Pro service name (e.g. `esm-infra`, `esm-apps`, `livepatch`). (namevar)
