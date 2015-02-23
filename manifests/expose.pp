# == Define: weave:expose
#
define weave::expose(
  $ip            = '',
  $create_bridge = false
) {
  validate_bool(is_ip_address($ip))
  validate_bool($create_bridge)

  exec { "weave-expose-${ip}":
    command => "${weave::bin_dir}/weave expose ${ip}",
  }

  if $create_bridge {
    exec { "weave-create-bridge-${ip}":
      command => "${weave::bin_dir}/weave create-bridge",
      require => Exec["weave-expose-${ip}"],
    }
  }
}
