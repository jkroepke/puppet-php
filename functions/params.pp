function php::params (
  Variant[String, Numeric] $key,
  Hash                     $options,
  Puppet::LookupContext    $context,
) {
  if 'php::version' in $key {
    # Avoid recursive lookup
    $context.not_found()
  }

  $php_version = lookup('php::version')
  $php_version_major = split($php_version, '.')[0]

  $params = case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['name'] {
        'Ubuntu': {
          case $php_version {
            /^5\.4/: {
              {
                'php::config_root'      => '/etc/php5',
                'php::fpm_pid_file'     => "/var/run/php/php${php_version}-fpm.pid",
                'php::fpm_error_log'    => '/var/log/php5-fpm.log',
                'php::fpm_service_name' => 'php5-fpm',
                'php::ext_tool_enable'  => '/usr/sbin/php5enmod',
                'php::ext_tool_query'   => '/usr/sbin/php5query',
                'php::package_prefix'   => 'php5-',
              }
            }
            /^[57].[0-9]/: {
              {
                'php::config_root'      => "/etc/php/${php_version}",
                'php::fpm_pid_file'     => "/var/run/php/php${php_version}-fpm.pid",
                'php::fpm_error_log'    => "/var/log/php${php_version}-fpm.log",
                'php::fpm_service_name' => "php${php_version}-fpm",
                'php::ext_tool_enable'  => "/usr/sbin/phpenmod -v ${php_version}",
                'php::ext_tool_query'   => "/usr/sbin/phpquery -v ${php_version}",
                'php::package_prefix'   => "php${php_version}-",
              }
            }
            default: {
              # Default php installation from Ubuntu official repository use the following paths until 16.04
              # For PPA please use the $php_version to override it.
              {
                'php::config_root'      => '/etc/php5',
                'php::fpm_pid_file'     => '/var/run/php5-fpm.pid',
                'php::fpm_error_log'    => '/var/log/php5-fpm.log',
                'php::fpm_service_name' => 'php5-fpm',
                'php::ext_tool_enable'  => '/usr/sbin/php5enmod',
                'php::ext_tool_query'   => '/usr/sbin/php5query',
                'php::package_prefix'   => 'php5-',
              }
            }
          }
        }
        default: {
          case $php_version {
            /^7\.[0-9]/: {
              {
                'php::config_root'      => "/etc/php/${php_version}",
                'php::fpm_pid_file'     => "/var/run/php/php${php_version}-fpm.pid",
                'php::fpm_error_log'    => "/var/log/php${php_version}-fpm.log",
                'php::fpm_service_name' => "php${php_version}-fpm",
                'php::ext_tool_enable'  => "/usr/sbin/phpenmod -v ${php_version}",
                'php::ext_tool_query'   => "/usr/sbin/phpquery -v ${php_version}",
                'php::package_prefix'   => "php${php_version}-",
              }
            }
            default: {
              {
                'php::config_root'      => '/etc/php5',
                'php::fpm_pid_file'     => '/var/run/php5-fpm.pid',
                'php::fpm_error_log'    => '/var/log/php5-fpm.log',
                'php::fpm_service_name' => 'php5-fpm',
                'php::ext_tool_enable'  => '/usr/sbin/php5enmod',
                'php::ext_tool_query'   => '/usr/sbin/php5query',
                'php::package_prefix'   => 'php5-',
              }
            }
          }
        }
      }
    }
    default: {
      {}
    }
  }

  if $key == 'php::version_major' {
    {
      'php::version_major' => $php_version_major,
    }
  }
  elsif $key in $params {
    $params[$key]
  }
  else {
    $context.not_found()
  }
}