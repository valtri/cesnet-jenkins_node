# Jenkins Node Puppet Module

[![Build Status](https://travis-ci.org/valtri/cesnet-jenkins_node.svg?branch=master)](https://travis-ci.org/valtri/cesnet-jenkins\_node)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with jenkins\_node](#setup)
    * [What jenkins\_node affects](#what-jenkins_node-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with jenkins\_node](#beginning-with-jenkins_node)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Module Parameters (`jenkins_node` class)](#parameters)
5. [Development - Guide for contributing to the module](#development)

## Module Description

Jenkins node setup for building packages in chroot environment using mock or pbuilder.

## Setup

### What jenkins\_node affects

* Packages: Java, build tools
* Sudo: pbuilder under *jenkins* user, cleanups
* Files:
 * config files for dput, mini-dinstall
 * user rpm macros
 * credentials (gpg, ssh)
 * build scripts checkout
* SELinux setup
* cron:
 * TODO: refresh images

### Setup Requirements

gnupg directory with key needs to be prepared locally at each Jenkins node or at the puppet master.

## Usage

    class{'jenkins_node':
      gpg_dir      => [
        "puppet:///extra_files/${::fqdn}/gnupg",
        "puppet:///extra_files/cluster-${::cluster}/gnupg",
      ],
      gpg_identity => 'Jenkins Builder <jenkins@emian.zcu.cz>',
      gpg_keys => {
        gpg-pubkey-64fa8786-516dbb49 => 'http://scientific.zcu.cz/repos/jenkins-builder.asc',
      },
    }

### SSH keys

They must be specified separately. For example:

    ssh_authorized_key{'root@myriads.zcu.cz':
      user => 'jenkins',
      type => 'ssh-dss',
      key => 'AAAA...',
    }

<a name="reference"></a>
## Reference

### Classes

* [**`jenkins_node`**](#class-jenkins_node): Jenkins Node

### Resources

* `jenkins_node::gpgkey_rpm` (internal): Import GPG key into rpm

<a name="class-jenkins_node"></a>
###`jenkins_node` class

<a name="parameters"></a>
#### Paramerers

#####`homedir`

Jenkins user home directory. Default: '/var/lib/jenkins'.

#####`gpg_dir`

GnuPG config directory with key pair. Default: undef.

Note, it is passed directly to source of *file* type.

#####`gpg_identity`

gnupg identity in the form of "Name &lt;email\_address&gt;". Default: "Jenkins Builder &lt;jenkins@${::fqdn}&gt;".

Used for rpm.

#####`gpg_keys`

Hash of gpg key name and gpg key URL pairs. Default: undef.

Used for import into rpm.

Example:

    gpg_keys => {
      gpg-pubkey-64fa8786-516dbb49 => 'http://scientific.zcu.cz/repos/jenkins-builder.asc'
    }

#####`jenkins_principals`

Array of Kerberos principals to authenticate to Jenkins node into *jenkins* user. Default: undef.

<a name="development"></a>
##Development

* Repository: [https://github.com/valtri/cesnet-jenkins\_node](https://github.com/valtri/cesnet-jenkins_node)
* Tests: see *.travis.yml*
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
