# == Resource jenkins_node::gpgkey_rpm
#
# Import GPG key into rpm.
#
define jenkins_node::gpgkey_rpm(
  $gpg_keys = undef,
) {
  if $gpg_keys {
    $gpg_keyid = $title
    $gpg_key_url = $gpg_keys[$title]

    exec{"jenkins-rpm-${title}":
      command => "rpm --import ${gpg_key_url}",
      path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      unless  => "rpm -q gpg-pubkey-${gpg_keyid}",
    }
  }
}
