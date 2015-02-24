# == Class: weave
#
# Module to install and configure Weave for Docker.
#
# === Parameters
#
# [*version*]
#   The package version to download, Defaults to latest_release.
#
# [*install_method*]
#   Defaults to `url` but can be `package` if you want to install via a system package.
#
# [*package_name*]
#   Only valid when the install_method == package. Defaults to `weave`.
#
# [*package_ensure*]
#   Only valid when the install_method == package. Defaults to `latest`.
#
# [*expose*]
#   An IP address to expose on Weave. will execute weave expose $expose.
#
# [*create_bridge*]
#   Boolean whether to create a bridge network or not. Should be used in conjunction
#   with expose.
#
# [*password*]
#   A password to use if we want to use weave launch -password
#
# [*peers*]
#   An array of cluster IP addresses to join on weave launch.
#
# [*download_url*]
#   URL to download the Weave executable from. Defaults to "https://github.com/zettio/weave/releases/tag/${version}/weave"
#
# [*bin_dir*]
#   The location of the Weave executable. Defaults to /usr/local/bin
#
class weave (
  $version           = $weave::params::version,
  $install_method    = $weave::params::install_method,
  $package_name      = $weave::params::package_name,
  $package_ensure    = $weave::params::package_ensure,
  $expose            = $weave::params::expose,
  $create_bridge     = $weave::params::create_bridge,
  $password          = $weave::params::password,
  $peers             = $weave::params::peers,
  $download_url      = "https://github.com/zettio/weave/releases/download/${version}/weave",
  $bin_dir           = '/usr/local/bin',
  $service_name      = $weave::params::service_name,
  $service_state     = $weave::params::service_state,
  $service_enable    = $weave::params::service_enable,
) inherits ::weave::params {
  validate_string($version)
  validate_string($password)
  validate_bool($create_bridge)
  validate_re($::osfamily, '^(Debian|RedHat)$', 'This module only works on Debian and Red Hat based systems.')
  validate_array($peers)

  if $expose {
    ensure_resource('weave::expose', "weave-expose-${expose}", { 'ip' => $expose, 'create_bridge' => $create_bridge })
  }

  class { 'weave::install': } ->
  class { 'weave::config': } ~>
  class { 'weave::service': } ->
  Class['weave']
}
