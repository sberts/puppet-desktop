# awscli
#
class desktop::awscli(
  String $user = 'ec2-user',
  Boolean $install_awscli = true,
) {
  if $install_awscli {
    package { 'awscli':
      ensure   => present,
      provider =>  pip,
    }

    if $operatingsystem == 'CentOS' {
      package { 'aws-sam-cli':
        ensure   => present,
        provider => pip,
      }
    } else {
      package { 'python-backports.ssl-match-hostname':
        ensure   => present,
      }
      ->package { 'aws-sam-cli':
        ensure   => present,
        provider => pip,
      }
    }
    vcsrepo { "/home/${user}/.aws-env":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/mdxp/aws-env.git',
      owner    => $user,
      group    =>  $user,
    }

    file { "/home/${user}/.aws":
      ensure => directory,
      owner  => $user,
      group  =>  $user,
    }

    file { "/home/${user}/.aws/credentials":
      ensure  => file,
      owner   => $user,
      group   => $user,
      replace => false,
      content =>  '[default]',
    }

    file { "/home/${user}/.bashrc-aws-env":
      ensure => file,
      owner  => $user,
      group  => $user,
      source =>  'puppet:///modules/desktop/bashrc-aws-env',
    }

    file_line { 'fileline-bashrc-aws-env':
      path => "/home/${user}/.bashrc",
      line =>  '. ~/.bashrc-aws-env',
    }
  }
}
