# aws
#
class desktop::aws(
  String $user           = 'ec2-user',
  Boolean $install_aws   = true,
  String $awscli_version = '2.0.30',
) {
  if $install_aws {
    exec { 'curl-awscliv2':
      command => "curl -LSso /usr/local/src/awscli-exe-linux-x86_64-${awscli_version}.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${awscli_version}.zip",
      path    => '/usr/bin',
      creates =>  "/usr/local/src/awscli-exe-linux-x86_64-${awscli_version}.zip",
    }
    ~> exec { 'unzip-awscliv2':
      command     => "unzip /usr/local/src/awscli-exe-linux-x86_64-${awscli_version}.zip -d /usr/local/share",
      path        => '/bin:/usr/bin',
      refreshonly =>  true,
    }
    ~> exec { 'install-awscliv2':
      command     => '/usr/local/share/aws/install',
      refreshonly =>  true,
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

    file_line { 'fileline-bashrc-aws-completer':
      path => "/home/${user}/.bashrc",
      line =>  "complete -C '/usr/local/bin/aws_completer' aws",
    }
  }
}
