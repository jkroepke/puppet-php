# Base class with global configuration parameters that pulls in all
# enabled components.
#
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install, defaults to 'present'.
#   Please note that 'absent' to remove packages is not supported!
#
# [*manage_repos*]
#   Include repository (dotdeb, ppa, etc.) to install recent PHP from
#
# [*fpm*]
#   Install and configure php-fpm
#
# [*fpm_service_enable*]
#   Enable/disable FPM service
#
# [*fpm_service_ensure*]
#   Ensure FPM service is either 'running' or 'stopped'
#
# [*fpm_service_name*]
#   This is the name of the php-fpm service. It defaults to reasonable OS
#   defaults but can be different in case of using php7.0/other OS/custom fpm service
#
# [*fpm_service_provider*]
#   This is the name of the service provider, in case there is a non
#   OS default service provider used to start FPM.
#   Defaults to 'undef', pick system defaults.
#
# [*fpm_pools*]
#   Hash of php::fpm::pool resources that will be created. Defaults
#   to a single php::fpm::pool named www with default parameters.
#
# [*fpm_global_pool_settings*]
#   Hash of defaults params php::fpm::pool resources that will be created.
#   Defaults to empty hash.
#
# [*fpm_inifile*]
#   Path to php.ini for fpm
#
# [*fpm_package*]
#   Name of fpm package to install
#
# [*fpm_user*]
#   The user that php-fpm should run as
#
# [*fpm_group*]
#   The group that php-fpm should run as
#
# [*dev*]
#   Install php header files, needed to install pecl modules
#
# [*composer*]
#   Install and auto-update composer
#
# [*pear*]
#   Install PEAR
#
# [*phpunit*]
#   Install phpunit
#
# [*apache_config*]
#   Manage apache's mod_php configuration
#
# [*proxy_type*]
#    proxy server type (none|http|https|ftp)
#
# [*proxy_server*]
#   specify a proxy server, with port number if needed. ie: https://example.com:8080.
#
# [*extensions*]
#   Install PHP extensions, this is overwritten by hiera hash `php::extensions`
#
# [*package_prefix*]
#   This is the prefix for constructing names of php packages. This defaults
#   to a sensible default depending on your operating system, like 'php-' or
#   'php5-'.
#
# [*config_root_ini*]
#   This is the path to the config .ini files of the extensions. This defaults
#   to a sensible default depending on your operating system, like
#   '/etc/php5/mods-available' or '/etc/php5/conf.d'.
#
# [*config_root_inifile*]
#   The path to the global php.ini file. This defaults to a sensible default
#   depending on your operating system.
#
# [*ext_tool_enable*]
#   Absolute path to php tool for enabling extensions in debian/ubuntu systems.
#   This defaults to '/usr/sbin/php5enmod'.
#
# [*ext_tool_query*]
#   Absolute path to php tool for querying information about extensions in
#   debian/ubuntu systems. This defaults to '/usr/sbin/php5query'.
#
# [*ext_tool_enabled*]
#   Enable or disable the use of php tools on debian based systems
#   debian/ubuntu systems. This defaults to 'true'.
#
# [*log_owner*]
#   The php-fpm log owner
#
# [*log_group*]
#   The group owning php-fpm logs
#
# [*embedded*]
#   Enable embedded SAPI
#
# [*pear_ensure*]
#   The package ensure of PHP pear to install and run pear auto_discover
#
# [*settings*]
#
# [*config_root*]
#   TODO: documentation
#
# [*fpm_pid_file*]
#   TODO: documentation
#
# [*fpm_error_log*]
#   TODO: documentation
#
# [*pear_package_suffix*]
#   TODO: documentation
#
# [*phpunit_source*]
#   TODO: documentation
#
# [*phpunit_path*]
#   TODO: documentation
#
# [*phpunit_max_age*]
#   TODO: documentation
#
# [*common_package_names*]
#   TODO: documentation
#
# [*cli_inifile*]
#   TODO: documentation
#
# [*common_package_suffixes*]
#   TODO: documentation
#
# [*fpm_config_file*]
#   TODO: documentation
#
# [*fpm_pool_dir*]
#   TODO: documentation
#
# [*root_group*]
#   TODO: documentation
#
# [*compiler_packages*]
#   TODO: documentation
#
# [*embedded_package_suffix*]
#   TODO: documentation
#
# [*embedded_inifile*]
#   TODO: documentation
#
#

class php (
  String $ensure,
  Optional[Pattern[/^[57].[0-9]/]] $version,
  Boolean $manage_repos,
  Boolean $fpm,
  $fpm_service_enable,
  $fpm_service_ensure,
  $fpm_service_name,
  $fpm_service_provider,
  Hash $fpm_pools,
  Hash $fpm_global_pool_settings,
  $fpm_inifile,
  $fpm_package,
  $fpm_user,
  $fpm_group,
  Boolean $embedded,
  Boolean $dev,
  Boolean $composer,
  Boolean $pear,
  String $pear_ensure,
  Boolean $phpunit,
  Boolean $apache_config,
  $proxy_type,
  $proxy_server,
  Hash $extensions,
  Hash $settings,
  String $package_prefix,
  Stdlib::Absolutepath $config_root_ini,
  Stdlib::Absolutepath $config_root_inifile,
  Optional[Stdlib::Absolutepath] $ext_tool_enable,
  Optional[Stdlib::Absolutepath] $ext_tool_query,
  Boolean $ext_tool_enabled,
  String $log_owner,
  String $log_group,
  $config_root,
  $fpm_pid_file,
  $fpm_error_log,
  $pear_package_suffix,
  $phpunit_source,
  $phpunit_path,
  $phpunit_max_age,
  $common_package_names,
  $cli_inifile,
  $common_package_suffixes,
  $fpm_config_file,
  $fpm_pool_dir,
  $root_group,
  $compiler_packages,
  $embedded_package_suffix,
  $embedded_inifile,
) {
  if $manage_repos {
    class { 'php::repo': }
    -> Anchor['php::begin']
  }

  anchor { 'php::begin': }
  -> class { 'php::packages': }
  -> class { 'php::cli':
    settings => $settings,
  }
  -> anchor { 'php::end': }

  # Configure global PHP settings in php.ini
  if $facts['os']['family'] != 'Debian' {
    Class['php::packages']
    -> class {'php::global':
      settings => $settings,
    }
    -> Anchor['php::end']
  }

  if $fpm { contain 'php::fpm' }
  if $embedded {
    if $facts['os']['family'] == 'RedHat' and $fpm {
      # Both fpm and embeded SAPIs are using same php.ini
      fail('Enabling both cli and embedded sapis is not currently supported')
    }

    Anchor['php::begin']
    -> class { 'php::embedded':
      settings => $settings,
    }
    -> Anchor['php::end']
  }
  if $dev {
    Anchor['php::begin']
    -> class { 'php::dev': }
    -> Anchor['php::end']
  }
  if $composer {
    Anchor['php::begin']
    -> class { 'php::composer':
      proxy_type   => $proxy_type,
      proxy_server => $proxy_server,
    }
    -> Anchor['php::end']
  }
  if $pear {
    Anchor['php::begin']
    -> class { 'php::pear':
      ensure => $pear_ensure,
    }
    -> Anchor['php::end']
  }
  if $phpunit {
    Anchor['php::begin']
    -> class { 'php::phpunit': }
    -> Anchor['php::end']
  }
  if $apache_config {
    Anchor['php::begin']
    -> class { 'php::apache_config':
      settings => $settings,
    }
    -> Anchor['php::end']
  }

  create_resources('php::extension', $extensions, {
    require => Class['php::cli'],
    before  => Anchor['php::end']
  })

  # On FreeBSD purge the system-wide extensions.ini. It is going
  # to be replaced with per-module configuration files.
  if $facts['os']['family'] == 'FreeBSD' {
    # Purge the system-wide extensions.ini
    file { '/usr/local/etc/php/extensions.ini':
      ensure  => absent,
      require => Class['php::packages'],
    }
  }
}
