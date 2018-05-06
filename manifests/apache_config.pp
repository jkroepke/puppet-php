# Install and configure php apache settings
#
# === Parameters
#
# [*inifile*]
#   The path to the ini php-apache ini file
#
# [*settings*]
#   Hash with nested hash of key => value to set in inifile
#
class php::apache_config(
  Stdlib::Absolutepath $inifile = $php::apache_inifile,
  Hash $settings                = {}
) {

  assert_private()

  $settings = deep_merge($settings, hiera_hash('php::apache::settings', {}))

  php::config { 'apache':
    file   => $inifile,
    config => $settings,
  }
}
