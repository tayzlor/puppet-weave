#### Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Usage](#usage)
4. [Limitations](#limitations)

## Overview

Puppet module for installing, configuring and managing [Weave](https://github.com/zettio/weave), the virtual network that connects
Docker containers deployed across multiple hosts.

## Requirements

If you install this from the git repository rather than from the forge, dependencies must be managed manually. This module requires:

* [garethr/docker](https://forge.puppetlabs.com/garethr/docker) - Required for acceptance tests. If not using this module (to install Docker) a working Docker installation is required for [Weave](https://github.com/zettio/weave) to run on top of.
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [nanliu/staging](https://forge.puppetlabs.com/nanliu/staging) - Only required if using URL download.

In order to run [Weave](https://github.com/zettio/weave) a kernel version after 3.5 is required, the newer the better.

## Usage

This module includes a single class:
```puppet
include 'weave'
```

By default this downloads the Weave source from Github and installs it under
/usr/local/bin/weave.

If you want to install via a package management system:

```puppet
class { 'weave':
  install_method => 'package',
  package_name   => 'weave',
  package_ensure => 'present',
}
```

If using in conjunction with [garethr/docker](https://forge.puppetlabs.com/garethr/docker) module.

```puppet
class { 'weave':
  require => Class['docker'],
}
```

By default this will run weave launch (on install) without connecting to any cluster peers.
If you want weave to launch with other peers in the cluster:

```puppet
class { 'weave':
  peers => ['168.0.0.1', '168.0.0.2'],
}
```

This will end up as ```weave launch 168.0.0.1 168.0.0.2```

If you want weave to expose a subnet you can also specify the expose parameter:

```puppet
class { 'weave':
  expose => '10.0.1.102/24',
}
```

This can also be used in conjunction with create_bridge:

```puppet
class { 'weave':
  expose        => '10.0.1.102/24',
  create_bridge => true,
}
```

This will end up running -

```shell
/usr/local/bin/weave expose 10.0.1.102/24
/usr/local/bin/weave create-bridge
```

## Limitations

It is possible to run this on Centos 6.5, but you will required a patched/upgraded kernel version (as [Weave](https://github.com/zettio/weave) requires Kernel 3.5 or greater). You might be also required to update the iptables package.

If you want some information around how to install kernel 3.10 on Centos 6.5 [check out this link](http://bicofino.io/blog/2014/10/25/install-kernel-3-dot-10-on-centos-6-dot-5/)
