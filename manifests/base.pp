class desktop::base() {
  if $operatingsystem == "CentOS" {
    package { 'epel-release':
      ensure => installed,
    }

    exec { 'yum-groupinstall-dev':
      command => 'yum groupinstall -y "Development Tools"',
      path    => '/usr/bin',
      creates => '/usr/bin/gcc',
    }
  }

  if $operatingsystem == "Ubuntu" {
    package { [ 'build-essential', 'dkms' ]:
      ensure => installed,
    }
  }

  if $operatingsystem == "CentOS" {
    package { [ 'bind-utils', 'nc' ]:
      ensure => installed,
    }
  }

  package { [ 'git',
    'wget',
    'tcpdump',
    'pylint',
    'net-tools' ]:
    ensure => installed,
  }
}
