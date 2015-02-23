# == Class: weave::service
#
# Class to manage the weave service daemon
#
# === Parameters
#
# [*peers*]
#   Cluster peers to connect to on launch.
#
class weave::service (
  $peers                = $weave::peers,
  $service_name         = $weave::service_name,
  $service_state        = $weave::service_state,
  $service_enable       = $weave::service_enable,
) {
  # Remove the current node IP address from the cluster if its in there.
  $peer_string = join($peers, ' ')
  $peers = regsubst($peer_string, "^${::ipaddress_eth0}$", '', 'G')

  service { 'weave':
    ensure     => $service_state,
    name       => $service_name,
    enable     => $service_enable,
    #hasstatus  => $hasstatus,
    #hasrestart => $hasrestart,
    #provider   => $provider,
  }

}
