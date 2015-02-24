# == Class weave::params
#
# This class is meant to be called from weave.
# It sets variables according to platform.
#
class weave::params {
  $install_method    = 'url'
  $package_name      = 'weave'
  $package_ensure    = 'latest'
  $version           = 'latest_release'
  $peers             = []
  $bin_dir           = '/usr/local/bin'
  $password          = undef
  $expose            = undef
  $create_bridge     = false
  $service_name      = 'weave'
  $service_state     = running
  $service_enable    = true
}
