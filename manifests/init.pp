# @summary Manage Ubuntu Pro subscription attachment
#
# Attaches or detaches the node to/from Ubuntu Pro.
# The token is expected to come from eYAML-encrypted Hiera data
# and is handled as Puppet Sensitive throughout — it never appears
# in logs, reports, the catalog, or on the target filesystem.
#
# Compatible with Puppet 8.x and OpenVox 8.x.
# Supports Ubuntu 22.04+ only.
#
# @param token
#   The Ubuntu Pro subscription token. Must be wrapped in Sensitive
#   (Hiera lookup of an eYAML-encrypted value does this automatically).
#   The token is passed to `pro attach` via stdin so it never appears
#   in the process table.
#
# @param ensure
#   Whether the system should be 'attached' or 'detached'.
#
# @param manage_package
#   Whether to ensure the ubuntu-pro-client package is present.
#
# @param package_name
#   Name of the Ubuntu Pro client package.
#
# @param enable_services
#   Optional list of Ubuntu Pro services to enable after attaching.
#   For example: ['esm-infra', 'esm-apps', 'livepatch'].
#
# @param disable_services
#   Optional list of Ubuntu Pro services to explicitly disable.
#
class ubuntu_pro (
  Sensitive[String[1]] $token,
  Enum['attached', 'detached'] $ensure           = 'attached',
  Boolean                      $manage_package   = true,
  String[1]                    $package_name     = 'ubuntu-pro-client',
  Array[String[1]]             $enable_services  = [],
  Array[String[1]]             $disable_services = [],
) {
  # Only supported on Ubuntu 22.04+
  unless $facts['os']['name'] == 'Ubuntu' {
    fail("ubuntu_pro: This module only supports Ubuntu, not ${facts['os']['name']}")
  }

  $os_major = Integer($facts['os']['release']['major'])
  if $os_major < 22 {
    fail("ubuntu_pro: Requires Ubuntu 22.04 or later, got ${facts['os']['release']['full']}")
  }

  if $manage_package {
    package { $package_name:
      ensure => present,
      before => Pro_attach['ubuntu_pro'],
    }
  }

  pro_attach { 'ubuntu_pro':
    ensure => $ensure,
    token  => $token,
  }

  # Manage optional service enablement after attachment
  $enable_services.each |String $service| {
    pro_service { $service:
      ensure  => 'enabled',
      require => Pro_attach['ubuntu_pro'],
    }
  }

  $disable_services.each |String $service| {
    pro_service { $service:
      ensure  => 'disabled',
      require => Pro_attach['ubuntu_pro'],
    }
  }
}
