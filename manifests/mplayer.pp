# mplayer
#
class desktop::mplayer(
  String $user             = 'ec2-user',
  Boolean $install_mplayer = true,
) {
  if $operatingsystem == "CentOS" {
  if $install_mplayer {
    package { 'nux-dextop-release':
      ensure   => installed,
      provider => rpm,
      source   => 'http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm',
    }
  }
  -> package { [ 'mplayer',
    'pulseaudio',
    'pavucontrol',
    'nfs-utils' ]:
    ensure  => installed,
    require => Package['epel-release'],
  }
} else {

package { 'mplayer':
  ensure => installed,
}

}
}
