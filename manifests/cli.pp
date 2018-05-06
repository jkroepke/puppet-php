# Install and configure php CLI
#
# === Parameters
#
# [*inifile*]
#   The path to the ini php5-cli ini file
#
# [*settings*]
#   Hash with nested hash of key => value to set in inifile
#
class php::cli(
  Stdlib::Absolutepath $inifile = $php::cli_inifile,
  Hash $settings                = {}
) {

  assert_private()

  $settings = deep_merge($settings, hiera_hash('php::cli::settings', {}))

  ::php::config { 'cli':
    file   => $inifile,
    config => $settings,
  }
}
