# passwordsafe
#
class desktop::passwordsafe(
  String $user                  = 'ec2-user',
  Boolean $install_passwordsafe = true,
) {
  if $operatingsystem == "CentOS" {
    # install pwsafe
    file { 'passwordsafe-src-rpm':
      ensure => file,
      path   => '/usr/local/src/passwordsafe-0.97BETA-3.src.rpm',
      source => 'puppet:///modules/desktop/passwordsafe-0.97BETA-3.src.rpm',
    }
    ->package { [ 'rpm-build',
    'wxGTK3',
    'wxGTK3-devel',
    'xerces-c',
    'xerces-c-devel',
    'libyubikey',
    'libyubikey-devel',
    'ykpers',
    'ykpers-devel',
    'libXt-devel',
    'libXtst-devel',
    'libuuid-devel' ]:
      ensure => present,
    }
    ->exec { 'rpmbuild':
      command => 'rpmbuild --rebuild /usr/local/src/passwordsafe-0.97BETA-3.src.rpm',
      path    => '/usr/bin',
      creates => '/rpmbuild/RPMS/x86_64/passwordsafe-0.97BETA-3.x86_64.rpm',
    }
    ->package { 'passwordsafe':
      ensure   => present,
      provider => rpm,
      source   => '/rpmbuild/RPMS/x86_64/passwordsafe-0.97BETA-3.x86_64.rpm',
    }
  } else {
    package { 'passwordsafe':
      ensure => present,
    }
  }
}
