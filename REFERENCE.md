# Reference

## Table of Contents

- [Classes](#classes)
  - [ubuntu_pro](#ubuntu_pro)
- [Resource Types](#resource-types)
  - [pro_attach](#pro_attach)
  - [pro_service](#pro_service)
- [Facts](#facts)
  - [ubuntu_pro_status](#ubuntu_pro_status)

## Classes

### `ubuntu_pro`

Manages Ubuntu Pro subscription attachment. Compatible with Puppet 8.x and OpenVox 8.x on Ubuntu 22.04+.

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `token` | `Sensitive[String[1]]` | *required* | The Ubuntu Pro subscription token. Must be stored in eYAML-encrypted Hiera data. Passed to `pro attach` via stdin — never exposed in process table, logs, or on disk. |
| `ensure` | `Enum['attached', 'detached']` | `'attached'` | Whether the system should be attached to or detached from Ubuntu Pro. |
| `manage_package` | `Boolean` | `true` | Whether to ensure the `ubuntu-pro-client` package is installed. |
| `package_name` | `String[1]` | `'ubuntu-pro-client'` | Name of the Ubuntu Pro client package. |
| `enable_services` | `Array[String[1]]` | `[]` | List of Ubuntu Pro services to enable after attaching (e.g. `esm-infra`, `esm-apps`, `livepatch`). |
| `disable_services` | `Array[String[1]]` | `[]` | List of Ubuntu Pro services to explicitly disable. |

## Resource Types

### `pro_attach`

Manages Ubuntu Pro subscription attachment state.

#### Properties

| Property | Values | Default | Description |
|----------|--------|---------|-------------|
| `ensure` | `attached`, `detached` | `attached` | Whether the system should be attached to Ubuntu Pro. |

#### Parameters

| Parameter | Description |
|-----------|-------------|
| `name` | An arbitrary name for this resource instance. *(namevar)* |
| `token` | The Ubuntu Pro subscription token (`Sensitive[String]`). Security measures: |

**Token security:**

- Automatically wrapped in `Sensitive` internally (raw strings are munged)
- All `is_to_s`, `should_to_s`, and `change_to_s` methods return `[redacted]`
- Passed to `pro attach` exclusively via stdin (never in process arguments)
- Scrubbed from any error messages before raising exceptions
- Validated to reject empty values

#### Provider: `cli`

Uses the `pro` CLI. Confined to `osfamily: Debian`. Checks attachment status via `pro api u.pro.status.is_attached.v1` with a fallback to `pro status --format json`.

---

### `pro_service`

Manages individual Ubuntu Pro services.

#### Properties

| Property | Values | Default | Description |
|----------|--------|---------|-------------|
| `ensure` | `enabled`, `disabled` | `enabled` | Whether the service should be enabled or disabled. |

#### Parameters

| Parameter | Description |
|-----------|-------------|
| `name` | The Ubuntu Pro service name (e.g. `esm-infra`, `esm-apps`, `livepatch`, `fips`, `fips-updates`, `cc-eal`, `cis`). *(namevar)* |

#### Provider: `cli`

Uses the `pro` CLI with `--assume-yes`. Checks service status via `pro status --format json`.

## Facts

### `ubuntu_pro_status`

Custom fact that reports the current Ubuntu Pro attachment state. **Never exposes the subscription token.**

#### Example output

```json
{
  "attached": true,
  "services": [
    { "name": "esm-infra", "status": "enabled" },
    { "name": "esm-apps", "status": "enabled" },
    { "name": "livepatch", "status": "enabled" }
  ],
  "account": "My Organization",
  "expires": "2027-01-01T00:00:00Z"
}
```

#### Fields

| Field | Type | Description |
|-------|------|-------------|
| `attached` | Boolean | Whether the system is attached to Ubuntu Pro. |
| `services` | Array | List of services with `name` and `status` fields. |
| `account` | String | The Ubuntu Pro account name (if attached). |
| `expires` | String | Subscription expiration date (if attached). |
| `error` | String | Present only if the `pro` command failed or was not found. |
