# == Class: jenkins_node
class jenkins_node (
  $homedir = $::jenkins_node::params::homedir,
  $gpg_dir = undef,
  $gpg_identity = "Jenkins Builder <jenkins@${::fqdn}>",
  $gpg_keys = undef,
  $jenkins_principals = undef,
  $ssh_keys = undef,
) inherits ::jenkins_node::params {
  include ::stdlib

  ensure_packages($::jenkins_node::packages)

  user{'jenkins':
    ensure => 'present',
    groups => $::jenkins_node::groups,
    home   => $::jenkins_node::homedir,
  }

  if $jenkins_principals {
    validate_array($jenkins_principals)
    User['jenkins']
    ->
    file{"${homedir}/.k5login":
      owner   => 'jenkins',
      group   => 'jenkins',
      content => join(concat($jenkins_principals, ['']), "\n"),
    }
  }

  if $gpg_dir {
    User['jenkins']
    ->
    file{"${homedir}/.gnupg":
      owner        => 'jenkins',
      group        => 'jenkins',
      ignore       => 'random_seed',
      purge        => false,
      recurse      => 'remote',
      recurselimit => 100,
      source       => $gpg_dir,
    }
  }

  file{'/etc/sudoers.d/jenkins':
    owner  => 'root',
    group  => 'root',
    mode   => '0440',
    source => 'puppet:///modules/jenkins_node/sudo-jenkins',
  }

  User['jenkins']
  ->
  exec{ 'git clone https://github.com/valtri/jenkins-scripts scripts':
    creates => "${homedir}/scripts",
    cwd     => $homedir,
    path    => '/sbin:/usr/sbin:/bin:/usr/bin',
  }

  case $::osfamily {
    'Debian': {
      file{"${homedir}/.pbuilderrc":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template('jenkins_node/pbuilderrc.erb'),
      }
      ->
      file{'/root/.pbuilderrc':
        ensure => 'link',
        source => "${homedir}/.pbuilderrc",
      }

      file{"${homedir}/.mini-dinstall.conf":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template('jenkins_node/mini-dinstall.conf.erb'),
      }

      file{"${homedir}/.mini-dinstall-externals.conf":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template('jenkins_node/mini-dinstall-externals.conf.erb'),
      }

      file{"${homedir}/.dput.cf":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => template('jenkins_node/dput.cf.erb'),
      }

      file{[
        "${homedir}/debian",
        "${homedir}/debian/stable",
        "${homedir}/debian/mini-dinstall",
        "${homedir}/debian/mini-dinstall/incoming",
        "${homedir}/debian-externals",
        "${homedir}/debian-externals/stable",
        "${homedir}/debian-externals/mini-dinstall/",
        "${homedir}/debian-externals/mini-dinstall/incoming",
      ]:
        ensure => 'directory',
        owner  => 'jenkins',
        group  => 'jenkins',
      }

      File["${homedir}/debian/stable"]
      ->
      exec{"${homedir}/debian/stable/Packages":
        command => "touch ${homedir}/debian/stable/Packages",
        creates => "${homedir}/debian/stable/Packages",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      }

      File["${homedir}/debian-externals/stable"]
      ->
      exec{"${homedir}/debian-externals/stable/Packages":
        command => "touch ${homedir}/debian-externals/stable/Packages",
        creates => "${homedir}/debian-externals/stable/Packages",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      }
    }

    'RedHat': {
      Package['mock'] -> User['jenkins']

      # TODO: vypnuty selinux?
      User['jenkins']
      ->
      exec{"semanage ${homedir}":
        command     => "semanage fcontext -a -e /home/SOME_USER '${homedir}'",
        path        => '/sbin:/usr/sbin:/bin:/usr/bin',
        subscribe   => User['jenkins'],
        refreshonly => true,
      }
      ->
      exec{"restorecon ${homedir}":
        command     => "restorecon -R -v '${homedir}'",
        path        => '/sbin:/usr/sbin:/bin:/usr/bin',
        subscribe   => User['jenkins'],
        refreshonly => true,
      }

      User['jenkins']
      ->
      file{"${homedir}/.rpmmacros":
        owner   => 'jenkins',
        group   => 'jenkins',
        content => "%_gpg_name ${gpg_identity}",
      }

      if $::jenkins_node::gpg_keys {
        $gpg_names = keys($::jenkins_node::gpg_keys)
        jenkins_node::gpgkey_rpm{ $gpg_names :
          gpg_keys => $::jenkins_node::gpg_keys,
        }
      }
    }

    default: {}
  }
}
