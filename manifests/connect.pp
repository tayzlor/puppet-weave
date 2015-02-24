# == Define: weave:connect
#
# === Parameters
#
# [*host*]
#   A host to connect to.
#
define weave::connect(
  $host = '',
) {
  exec { "weave-connect-${host}":
    command => "weave connect ${host}",
    path    => $weave::bin_dir,
  }
}
