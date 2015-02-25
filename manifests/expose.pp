# == Define: weave:expose
#
# === Parameters
#
# [*ip*]
#   An IP address to expose for the Weave bridge.
#   Will execute weave expose [IP].
#
class weave::expose(
  $ip = undef,
) {
  include weave

  if ! is_ip_address($ip) {
    fail('weave::expose::ip should be an IP address.')
  }

  exec { "weave-expose-${ip}":
    command => "weave expose ${ip}",
    path    => [$weave::bin_dir,'/sbin','/bin','/usr/bin'],
    user    => 'root',
    require => Class['weave::install']
  }
}
