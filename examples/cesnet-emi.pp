#
# Info about this use-case:
#
# * jenkins home is in the /scratch (mountpoint with non-persitent storage)
# * the node is accessed via Kerberos
# * GPG key specified
# * external repositories taken from the build scripts example
#

$jenkins_homedir='/scratch'

class{'::jenkins_node':
  homedir            => $jenkins_homedir,
  jenkins_principals => [
    'jenkins/emian.zcu.cz@ZCU.CZ',
    'valtri@ZCU.CZ',
  ],
  gpg_keyid          => '64fa8786',
  gpg_identity       => 'Jenkins Builder <jenkins@emian.zcu.cz>',
  gpg_keys           => {
    '64fa8786' => 'http://scientific.zcu.cz/repos/jenkins-builder.asc',
  },
}

Exec['download-jenkins-scripts']
->
file{"${jenkins_homedir}/scripts/repos.sh":
  ensure => link,
  target => 'examples/repos.sh',
}
