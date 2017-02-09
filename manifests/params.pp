# == Class: jenkins_node::params

class jenkins_node::params {
  include ::stdlib

  $groups = $::osfamily ? {
    /RedHat/ => ['mock'],
    /Debian/ => [],
    default  => [],
  }

  $homedir = '/var/lib/jenkins'

  case $::osfamily {
    'Debian': {
      $package_java = $::lsbdistcodename ? {
        'squeeze'        => 'openjdk-6-jre-headless',
        'wheezy'         => 'openjdk-7-jre-headless',
        'jessie'         => 'openjdk-7-jre-headless',
        'stretch'        => 'openjdk-8-jre-headless',

        /precise|trusty/ => 'openjdk-7-jre-headless',
        /utopic|vivid/   => 'openjdk-8-jre-headless',
      }

      $package_python = $::lsbdistcodename ? {
        /squeeze|wheezy/ => [],
        /precise/        => [],
        default          => ['dh-python'],
      }

      $packages_os = [
        'cdbs',
        'dpkg-dev',
        'dput',
        'maven-debian-helper',
        'mini-dinstall',
        'pbuilder',
        'dh-autoreconf',
        'ruby',
      ]
    }
    'RedHat': {
      # SL7
      $package_java = 'java-1.8.0-openjdk-headless'

      $package_python = []

      $packages_os = [
        'createrepo_c',
        'rpm-build',
        'rpm-sign',
        'mock',
        'policycoreutils-python',
      ]
    }
    default: {
      fail("${::osfamily} (${::operatingsystem}) not supported")
    }
  }

  $packages_common = [
    'git',
    'unzip',
    'pbzip2',
    'pigz',
    'rubygems',
  ]

  $packages = concat($packages_common, $packages_os, [$package_java], $package_python)

  $osver = pick(getvar('::lsbmajdistrelease'), getvar('::operatingsystemrelease'))
  $platforms = "${::osfamily}-${::operatingsystem}-${osver}" ? {
    /RedHat-.*-5/      => ['epel-5-i386', 'epel-5-x86_64'],
    /RedHat/           => ['epel-5-i386', 'epel-5-x86_64', 'epel-6-i386', 'epel-6-x86_64', 'epel-7-x86_64', 'fedora-rawhide-i386', 'fedora-rawhide-x86_64'],
    /Debian-Debian-7/  => ['debian-7-x86_64'],
    /Debian-Debian/    => ['debian-7-x86_64', 'debian-8-x86_64', 'debian-9-x86_64'],
    /Debian-Ubuntu-12/ => ['ubuntu-12-x86_64'],
    /Debian-Ubuntu/    => ['ubuntu-12-x86_64', 'ubuntu-14-x86_64', 'ubuntu-16-x86_64'],
    default            => [],
  }
}
