# atom
#
class desktop::atom(
  String $user = 'ec2-user',
  Boolean $install_atom = true,
) {
  if $install_atom {

    # TODO: add support for Ubuntu
    #

    if $operatingsystem == "CentOS" {

      exec { 'rpm-import-atom-gpgkey':
        command     => 'rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey',
        path        => '/usr/bin',
        refreshonly => true,
      }
      file { 'atom-repo':
        ensure => file,
        path   => '/etc/yum.repos.d/atom.repo',
        source => 'puppet:///modules/desktop/atom.repo',
        notify => Exec['rpm-import-atom-gpgkey'],
      }
      ->package { 'atom':
        ensure  => present,
        require => Exec['rpm-import-atom-gpgkey'],
      }
      exec { 'apm-install-atom-ide-ui':
        command     => 'apm install atom-ide-ui',
        path        => '/usr/bin',
        refreshonly => true,
        subscribe   => Package['atom'],
      }
      exec { 'apm-install-ide-puppet':
        command     => 'apm install ide-puppet',
        path        => '/usr/bin',
        refreshonly => true,
        subscribe   => Package['atom'],
      }
      exec { 'apm-install-language-puppet':
        command     => 'apm install language-puppet',
        path        => '/usr/bin',
        refreshonly => true,
        subscribe   => Package['atom'],
      }

    } else {
      #package { 'atom':
      #  ensure => installed,
      #}
    }
  }
}
