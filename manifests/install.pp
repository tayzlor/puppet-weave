# == Class weave::install
#
# This class is called from weave for install.
#
class weave::install {

  if $weave::install_method == 'url' {

    if $::operatingsystem != 'darwin' {
      ensure_packages(['unzip'])
    }
    staging::file { 'weave':
      source => $weave::download_url,
      target => "${weave::bin_dir}/weave",
    } ->
    file { "${weave::bin_dir}/weave":
      owner => 'root',
      group => 0, # 0 instead of root because OS X uses "wheel".
      mode  => '0555',
    }
  } elsif $weave::install_method == 'package' {
    package { $weave::package_name:
      ensure => $weave::package_ensure,
    }
  } else {
    fail("The provided install method ${weave::install_method} is invalid")
  }
}
