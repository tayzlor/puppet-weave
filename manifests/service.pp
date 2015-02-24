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
  $cluster_peers = strip(join((regsubst($peers, "^${::ipaddress_eth0}$", '', 'G')), ' '))

  case $::osfamily {
    'Debian': {
      $hasstatus     = true
      $hasrestart    = false

      file { '/etc/init/weave.conf':
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        content => template('weave/etc/init/weave.conf.erb'),
      }
      file { '/etc/init.d/weave':
        ensure => 'link',
        target => '/lib/init/upstart-job',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
        force  => true,
        notify => Service['weave'],
      }
      file { "/etc/default/${service_name}":
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        force   => true,
        content => template('weave/etc/default/weave.erb'),
        notify  => Service['weave'],
      }
    }
    'RedHat': {
      if ($::operatingsystem == 'Fedora') or (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        file { '/etc/systemd/system/weave.service':
          ensure  => present,
          mode    => '0644',
          owner   => 'root',
          group   => 'root',
          force   => true,
          content => template('weave/etc/systemd/system/weave.service.erb'),
          notify  => Service['weave'],
        }
        $hasrestart = false
      } else {
        file { '/etc/init.d/weave':
          ensure  => present,
          mode    => '0555',
          owner   => 'root',
          group   => 'root',
          force   => true,
          content => template('weave/etc/init.d/weave.erb'),
          notify  => Service['weave'],
        }
        $hasrestart = true
      }
      $hasstatus = undef

      file { '/etc/sysconfig/weave':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        force   => true,
        content => template('weave/etc/sysconfig/weave.erb'),
        notify  => Service['weave'],
      }
    }
    default: {
      fail('Weave needs a Debian or RedHat based system.')
    }
  }

  $provider = $::operatingsystem ? {
    'Ubuntu' => 'upstart',
    default  => undef,
  }

  service { 'weave':
    ensure     => $service_state,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $provider,
  }
}
