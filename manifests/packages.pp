# Install common PHP packages
#
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install
#
# [*names*]
#   List of the names of the package to install
#
# [*names_to_prefix*]
#   List of packages names that should be prefixed with the common
#   package prefix `$php::package_prefix`
#
class php::packages (
  String $ensure         = $php::ensure,
  Boolean $manage_repos  = $php::manage_repos,
  Array $names_to_prefix = prefix($php::common_package_suffixes, $php::package_prefix),
  Array $names           = $php::common_package_names,
) {

  assert_private()

  $real_names = union($names, $names_to_prefix)
  if $facts['os']['family'] == 'debian' {
    if $manage_repos {
      include apt
      Class['apt::update'] -> Package[$real_names]
    }
    package { $real_names:
      ensure => $ensure,
    }
  } else {
    package { $real_names:
      ensure => $ensure,
    }
  }
}
