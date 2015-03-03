# == Class: weave:expose
#
# === Parameters
#
# [*ip*]
#   An IP address to expose as the Weave bridge.
#   Will execute weave expose [ip].
#
class weave::expose(
  $ip = undef,
) {
  if ! is_ip_address($ip) {
    fail('weave::expose::ip should be an IP address.')
  }

  exec { "weave-expose-${ip}":
    command => "weave expose ${ip}",
    path    => [$weave::bin_dir,'/sbin','/bin','/usr/bin'],
    user    => 'root',
    unless  => "ifconfig weave | grep ${ip}"
    require => Class['weave::install']
  }
}
