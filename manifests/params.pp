# == Class: jenkins_node::params

class jenkins_node::params {
  $groups = $::osfamily ? {
    /RedHat/ => ['mock'],
    /Debian/ => [],
    default  => [],
  }

  $homedir = '/var/lib/jenkins'

  case $::osfamily {
    'Debian', 'Ubuntu': {
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
        'dput',
        'mini-dinstall',
        'pbuilder',
        'dh-autoreconf',
      ]
    }
    'RedHat': {
      # SL7
      $package_java = 'java-1.8.0-openjdk-headless'

      $package_python = []

      $packages_os = [
        'createrepo_c',
        'rpm-sign',
        'git',
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
  ]

  $packages = concat($packages_common, $packages_os, [$package_java], $package_python)
}
