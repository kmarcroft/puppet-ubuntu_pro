# @summary Manage Ubuntu Landscape client registration
#
# Configures and manages landscape-client using /etc/landscape/client.conf.
# Registration secrets should be provided as Sensitive values from eYAML.
#
# @param ensure
#   Whether Landscape client should be registered or disabled.
#
# @param registration_key
#   Landscape account registration key (Sensitive).
#
# @param account_name
#   Landscape account name.
#
# @param computer_title
#   Optional computer title shown in Landscape.
#
# @param tags
#   Optional Landscape tags.
#
# @param url
#   Landscape message-system URL.
#
# @param ping_url
#   Landscape ping URL.
#
# @param ssl_public_key
#   Optional CA certificate path for SSL verification.
#
# @param manage_package
#   Whether to manage the landscape-client package.
#
# @param package_name
#   Name of the Landscape client package.
#
class ubuntu_pro::landscape (
  Enum['registered', 'disabled'] $ensure = 'registered',
  Optional[Sensitive[String[1]]] $registration_key = undef,
  Optional[String[1]] $account_name = undef,
  Optional[String[1]] $computer_title = undef,
  Array[String[1]] $tags = [],
  String[1] $url = 'https://landscape.canonical.com/message-system',
  String[1] $ping_url = 'http://landscape.canonical.com/ping',
  Optional[String[1]] $ssl_public_key = undef,
  Boolean $manage_package = true,
  String[1] $package_name = 'landscape-client',
) {
  if $ensure == 'registered' {
    if $registration_key == undef {
      fail('ubuntu_pro::landscape: registration_key is required when ensure=registered')
    }
    if $account_name == undef {
      fail('ubuntu_pro::landscape: account_name is required when ensure=registered')
    }

    if $manage_package {
      package { $package_name:
        ensure => present,
      }
    }

    file { '/etc/default/landscape-client':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "RUN=1\n",
    }

    $effective_title = $computer_title ? {
      undef   => $trusted['certname'],
      default => $computer_title,
    }

    $registration_key_value = $registration_key.unwrap
    $account_name_value = $account_name

    file { '/etc/landscape/client.conf':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0600',
      show_diff => false,
      content   => epp('ubuntu_pro/landscape_client.conf.epp', {
          'url'              => $url,
          'ping_url'         => $ping_url,
          'account_name'     => $account_name_value,
          'registration_key' => $registration_key_value,
          'computer_title'   => $effective_title,
          'tags'             => $tags,
          'ssl_public_key'   => $ssl_public_key,
      }),
      require   => Package[$package_name],
    }

    service { 'landscape-client':
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/landscape/client.conf', '/etc/default/landscape-client'],
      require   => Package[$package_name],
    }
  } else {
    service { 'landscape-client':
      ensure => stopped,
      enable => false,
    }
  }
}
