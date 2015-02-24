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
  include weave
  exec { "weave-connect-${host}":
    command => "weave connect ${host}",
    path    => [$weave::bin_dir,'/sbin','/bin','/usr/bin'],
    user    => 'root',
    require => Class['weave::install']
  }
}
