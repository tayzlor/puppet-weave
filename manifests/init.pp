# == Class: weave
#
# Full description of class weave here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
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
  $download_url      = "https://github.com/zettio/weave/archive/${version}.zip",
  $bin_dir           = '/usr/local/bin',
  $service_name      = $weave::params::service_name,
  $service_state     = $weave::params::service_state,
  $service_enable     = $weave::params::service_enable,
) inherits ::weave::params {
  validate_bool($create_bridge)
  validate_array($peers)

  if $expose {
    validate_bool(is_ip_address($expose))
    create_resources(weave::expose, { ip => $expose, create_bridge => $create_bridge})
  }

  class { 'weave::install': } ->
  class { 'weave::config': } ~>
  class { 'weave::service': } ->
  Class['weave']

  Class['weave'] -> Docker::Expose <||>
  Class['weave'] -> Docker::Connect <||>
}
