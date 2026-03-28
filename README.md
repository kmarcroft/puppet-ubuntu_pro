# ubuntu_pro

Manage Ubuntu Pro subscription attachment securely via Puppet.

## Security Architecture

This module is designed with a **zero-exposure guarantee** for the Ubuntu Pro subscription token:

| Layer | Protection |
|-------|-----------|
| **Hiera** | Token stored exclusively in eYAML-encrypted data — ciphertext only in VCS |
| **Puppet catalog** | Token typed as `Sensitive[String]` — Puppet redacts it from compiled catalogs |
| **Puppet logs** | `is_to_s` / `should_to_s` overrides return `[redacted]` — token never in logs or reports |
| **Process table** | Token passed to `pro attach` via **stdin** only — never appears in `/proc/<pid>/cmdline` or `ps` output |
| **Filesystem** | Token is **never written to disk** on the managed node — no temp files, no config files |
| **Error output** | Any error messages from `pro` are scrubbed to replace the token with `[REDACTED]` before raising |

## Setup Requirements

1. **eYAML** configured on your Puppet Server ([setup guide](https://github.com/voxpupuli/hiera-eyaml))
2. **Ubuntu Pro client** (`ubuntu-advantage-tools`) — the module installs it by default
3. A valid **Ubuntu Pro subscription token** from <https://ubuntu.com/pro/dashboard>

## Quick Start

### 1. Encrypt your token

```bash
eyaml encrypt -s 'C1xxxxxxxxxxxxxxxxxxxxxxxxxx'
```

### 2. Store in eYAML Hiera data

In your control repo (e.g. `data/common.eyaml`):

```yaml
ubuntu_pro::token: >
    ENC[PKCS7,MIIBygYJKoZIhvcNAQ...]
```

### 3. Classify your nodes

```puppet
include ubuntu_pro
```

Or with explicit parameters:

```puppet
class { 'ubuntu_pro':
  ensure          => 'attached',
  token           => Sensitive(lookup('ubuntu_pro::token')),
  enable_services => ['esm-infra', 'esm-apps', 'livepatch'],
}
```

## Usage

### Attach to Ubuntu Pro (default)

```yaml
# data/common.eyaml
ubuntu_pro::token: >
    ENC[PKCS7,...]

# data/common.yaml
ubuntu_pro::ensure: attached
ubuntu_pro::enable_services:
  - esm-infra
  - esm-apps
```

### Detach from Ubuntu Pro

```yaml
ubuntu_pro::ensure: detached
```

### Per-node token override

```yaml
# data/nodes/web01.example.com.eyaml
ubuntu_pro::token: >
    ENC[PKCS7,...]
```

## Reference

### Class: `ubuntu_pro`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `token` | `Sensitive[String[1]]` | *required* | Ubuntu Pro token (eYAML encrypted) |
| `ensure` | `Enum['attached','detached']` | `attached` | Desired state |
| `manage_package` | `Boolean` | `true` | Whether to manage `ubuntu-advantage-tools` |
| `package_name` | `String[1]` | `ubuntu-advantage-tools` | Package name |
| `enable_services` | `Array[String[1]]` | `[]` | Services to enable after attach |
| `disable_services` | `Array[String[1]]` | `[]` | Services to explicitly disable |

### Custom Types

#### `pro_attach`

Manages the Ubuntu Pro attachment state. Token is `Sensitive` and passed via stdin.

#### `pro_service`

Manages individual Ubuntu Pro services (`esm-infra`, `esm-apps`, `livepatch`, `fips`, etc.).

### Custom Fact: `ubuntu_pro_status`

Reports attachment status and enabled services. **Never contains the token.**

```json
{
  "attached": true,
  "services": [
    {"name": "esm-infra", "status": "enabled"},
    {"name": "esm-apps", "status": "enabled"}
  ],
  "account": "My Org",
  "expires": "2027-01-01T00:00:00Z"
}
```

## Hiera eYAML Setup

If you haven't set up eYAML yet:

```bash
# On the Puppet Server
puppetserver gem install hiera-eyaml
eyaml createkeys

# Move keys to a secure location
mkdir -p /etc/puppetlabs/puppet/eyaml
mv keys/*.pem /etc/puppetlabs/puppet/eyaml/
chown puppet:puppet /etc/puppetlabs/puppet/eyaml/*.pem
chmod 0400 /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
chmod 0440 /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
```

Ensure your `hiera.yaml` includes the eYAML backend:

```yaml
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "Encrypted data"
    lookup_key: eyaml_lookup_key
    paths:
      - "nodes/%{trusted.certname}.eyaml"
      - "common.eyaml"
    options:
      pkcs7_private_key: /etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem
      pkcs7_public_key: /etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem
  - name: "Common YAML"
    paths:
      - "nodes/%{trusted.certname}.yaml"
      - "common.yaml"
```

## Limitations

- Ubuntu only (20.04, 22.04, 24.04)
- Requires Puppet 7+ or 8+
- The `pro` CLI must be available on the target system

## Development

```bash
bundle install
bundle exec rake spec      # Run unit tests
bundle exec rake lint       # Puppet lint
bundle exec rake validate   # Full validation
```
