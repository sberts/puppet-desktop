# motd
#
class desktop::motd() {
  file { '/etc/update-motd.d/50-motd-news':
    ensure => absent,
  }
  file { '/etc/update-motd.d/10-help-text':
    ensure => absent,
  }
}
