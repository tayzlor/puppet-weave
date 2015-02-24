# == Define: weave:expose
#
# === Parameters
#
# [*ip*]
#   An IP address to expose on Weave. will execute weave expose [IP].
#
# [*create_bridge*]
#   Boolean whether to create a bridge network or not.
#
define weave::expose(
  $ip            = undef,
  $create_bridge = false
) {
  include weave

  validate_bool($create_bridge)
  if ! is_ip_address($ip) {
    fail('weave::expose::ip should be an IP address.')
  }

  exec { "weave-expose-${ip}":
    command => "weave expose ${ip}",
    path    => [$weave::bin_dir,'/sbin','/bin','/usr/bin'],
    user    => 'root',
    require => Class['weave::install']
  }

  if $create_bridge {
    exec { "weave-create-bridge-${ip}":
      command => 'weave create-bridge',
      path    => [$weave::bin_dir,'/sbin','/bin','/usr/bin'],
      user    => 'root',
      require => [ Exec["weave-expose-${ip}"], Class['weave::install'] ]
    }
  }
}
