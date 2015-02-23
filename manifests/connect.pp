# == Define: weave:connect
#
define weave::connect(
  $host = '',
) {
  exec { "weave-connect-${host}":
    command => "${weave::bin_dir}/weave connect ${host}",
  }
}
