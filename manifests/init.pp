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
# @param manage_landscape
#   Whether to manage Landscape client registration.
#
# @param landscape_ensure
#   Whether Landscape client should be registered or disabled.
#
# @param landscape_registration_key
#   Landscape registration key (store in eYAML as Sensitive data).
#
# @param landscape_account_name
#   Landscape account name for client registration.
#
# @param landscape_computer_title
#   Optional Landscape computer title (defaults to certname).
#
# @param landscape_tags
#   Optional list of Landscape tags.
#
# @param landscape_url
#   Landscape message-system URL.
#
# @param landscape_ping_url
#   Landscape ping URL.
#
# @param landscape_ssl_public_key
#   Optional CA certificate path for Landscape SSL verification.
#
class ubuntu_pro (
  Sensitive[String[1]] $token,
  Enum['attached', 'detached'] $ensure           = 'attached',
  Boolean                      $manage_package   = true,
  String[1]                    $package_name     = 'ubuntu-pro-client',
  Array[String[1]]             $enable_services  = [],
  Array[String[1]]             $disable_services = [],
  Boolean                      $manage_landscape = false,
  Enum['registered', 'disabled'] $landscape_ensure = 'registered',
  Optional[Sensitive[String[1]]] $landscape_registration_key = undef,
  Optional[String[1]]            $landscape_account_name     = undef,
  Optional[String[1]]            $landscape_computer_title   = undef,
  Array[String[1]]               $landscape_tags             = [],
  String[1]                      $landscape_url              = 'https://landscape.canonical.com/message-system',
  String[1]                      $landscape_ping_url         = 'http://landscape.canonical.com/ping',
  Optional[String[1]]            $landscape_ssl_public_key   = undef,
) {
  # Only supported on Ubuntu 22.04+
  unless $facts['os']['name'] == 'Ubuntu' {
    fail("ubuntu_pro: This module only supports Ubuntu, not ${facts['os']['name']}")
  }

  $os_major = Integer($facts['os']['release']['full'].split('\.')[0])
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

  if $manage_landscape {
    if $landscape_ensure == 'registered' {
      if $landscape_registration_key == undef {
        fail('ubuntu_pro: landscape_registration_key is required when manage_landscape=true and landscape_ensure=registered')
      }
      if $landscape_account_name == undef {
        fail('ubuntu_pro: landscape_account_name is required when manage_landscape=true and landscape_ensure=registered')
      }
    }

    class { 'ubuntu_pro::landscape':
      ensure           => $landscape_ensure,
      registration_key => $landscape_registration_key,
      account_name     => $landscape_account_name,
      computer_title   => $landscape_computer_title,
      tags             => $landscape_tags,
      url              => $landscape_url,
      ping_url         => $landscape_ping_url,
      ssl_public_key   => $landscape_ssl_public_key,
    }
  }
}
