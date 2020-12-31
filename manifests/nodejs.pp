# nodejs
#
class desktop::nodejs(
  Boolean $install_nodejs = true,
  String $nodejs_version = 'lts.x',
) {
  file { 'nodejs-setup':
    ensure => file,
    path => "/usr/local/src/setup_${nodejs_version}",
    owner => root,
    group => root,
    mode => '0755',
    source => "puppet:///modules/desktop/setup_${nodejs_version}",
  }
  ~> exec { 'nodejs-setup':
    command     => "setup_${nodejs_version}",
    path        => '/usr:/usr/bin:/usr/local/src',
    refreshonly =>  true,
  }
  -> package { 'nodejs':
    ensure => installed,
  }
  -> exec { 'exec-npm-aws-sso-creds-helper':
    command => 'npm install -g aws-sso-creds-helper',
    path => '/bin:/usr/bin',
  }
}
