# desktop
#
class desktop(
  String $user               = 'sberts',
  Boolean $install_ssh_agent = true,
  Boolean $install_vim       = true,
  Boolean $install_atom      = true,
  Boolean $install_ansible   = true,
  Boolean $install_fabric    = true,
  Boolean $install_go        = true,
  Boolean $install_java      = true,
  Boolean $install_docker    = true,
  Boolean $install_awscli    = true,
  Boolean $install_openstack = true,
  Boolean $install_i3        = true,
  Boolean $install_chrome    = true,
  Boolean $install_xrdp      = true,
  Boolean $install_mplayer   = true,
  Boolean $install_passwordsafe = true,
  Boolean $custom_lilyterm   = true,
  Integer $display_width     = 1920,
  Array $chrome_bookmarks    = [],
) {
  include desktop::base

  package { 'tmux':
    ensure => installed,
  }
  file { "/home/${user}/.bashrc":
    ensure => file,
    owner => $user,
  }
  file_line { 'export-term-tmux':
    path =>  "/home/${user}/.bashrc",
    line => 'alias tmux="TERM=screen-256color tmux"',
  }

  # powerline
  if $::operatingsystem == 'CentOS' {
    $powerlinepath = '/usr/lib/python2.7/site-packages/powerline'
  } else {
    $powerlinepath = '/usr/local/lib/python2.7/dist-packages/powerline'
  }
  if $::operatingsystem == 'Ubuntu' {
    package { 'python3-pip':
      ensure => installed,
    }
    ->package { 'python3-powerline-status':
      name     => 'powerline-status',
      ensure   => installed,
      provider => pip3,
    }
  }
  package { 'python-pip':
    ensure => installed,
  }
  ->package { 'powerline-status':
    ensure   => installed,
    provider => pip,
  }
  ->file { "${powerlinepath}/config_files/config.json":
    ensure => file,
    owner  => root,
    group  => root,
    source => 'puppet:///modules/desktop/powerline-config.json',
  }
  file { "/home/${user}/.tmux.conf":
    ensure => file,
    owner  => $user,
    group  => $user,
    mode   => '0600',
  }
  ->file_line { 'tmuxconf-powerline':
    path  => "/home/${user}/.tmux.conf",
    line  => "source \"${powerlinepath}/bindings/tmux/powerline.conf\"",
    match => "powerline.conf",
  }

  file_line { 'root-bashrc-powerline':
    path  => '/root/.bashrc',
    line  => ". ${powerlinepath}/bindings/bash/powerline.sh",
    match => "powerline.sh",
  }

  file_line { 'bashrc-powerline':
    path => "/home/${user}/.bashrc",
    line => ". ${powerlinepath}/bindings/bash/powerline.sh",
  }

  if $install_ssh_agent {
    file { "/home/${user}/.bashrc-sshagent":
      ensure => file,
      owner  => $user,
      group  => $user,
      mode   => '0640',
      source => 'puppet:///modules/desktop/dotbashrc-sshagent',
    }
    ->file_line { 'bashrc-sshagent':
      path => "/home/${user}/.bashrc",
      line => ". /home/${user}/.bashrc-sshagent",
    }
  }

  class { 'desktop::vim':
    user        => $user,
    install_vim => $install_vim,
  }

  # ansible
  if $install_ansible {
    package { 'ansible':
      ensure   => present,
      provider => pip,
    }
  }

  # fabric
  if $install_fabric {
    package { 'fabric':
      ensure   => present,
      provider => pip,
    }
  }

  # java
  if $::operatingsystem == 'CentOS' {
    $javapackage = [ 'java', 'java-devel' ]
  } else {
    $javapackage = [ 'default-jre', 'default-jdk' ]
  }
  if $install_java {
    package { $javapackage:
      ensure => installed,
    }
  }

  # go
  if $install_go {
    exec { 'curl-go':
      command => 'curl -LSso /usr/local/src/go1.11.linux-amd64.tar.gz https://dl.google.com/go/go1.11.linux-amd64.tar.gz',
      path    => '/usr/bin',
      creates =>  '/usr/local/src/go1.11.linux-amd64.tar.gz',
    }
    ~> exec { 'untar-go':
      command     => 'tar -C /usr/local -xzf /usr/local/src/go1.11.linux-amd64.tar.gz',
      path        => '/bin:/usr/bin',
      refreshonly =>  true,
    }

    file_line { 'export-path-go':
      path => "/home/${user}/.bashrc",
      line =>  'export PATH=$PATH:/usr/local/go/bin',
    }
  }

  # install docker
  if $install_docker {
    if $operatingsystem == 'CentOS' {
      exec { 'yum-install-docker-repo':
        command => 'yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo',
        path    => '/usr/bin',
        creates =>  '/etc/yum.repos.d/docker-ce.repo',
      }
      user { $user:
        groups =>  [ 'wheel', 'docker' ],
      }
    }

    if $::operatingsystem == 'Ubuntu' {
      exec { 'docker-apt-key-add':
        command     => 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -',
        path        => '/usr/bin',
        refreshonly => true,
      }
      exec { 'docker-add-apt-repo':
        command => 'add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"',
        path    => [ '/bin', '/usr/bin' ],
        unless  => 'grep docker /etc/apt/sources.list',
        notify  => Exec['docker-apt-key-add'],
      }
      user { $user:
        groups =>  [ 'sudo', 'docker' ],
      }
    }

    package { 'docker-ce':
      ensure =>  installed,
    }
    ->service { 'docker':
      ensure => running,
      enable =>  true,
    }
  }

  class { 'desktop::awscli':
    user           => $user,
    install_awscli => $install_awscli,
  }

  # install openstack client 
  if $install_openstack {
    if $operatingsystem == 'CentOS' {
      package { 'python-devel':
        ensure => installed,
      }
    }
    package { [ 'python-novaclient',
    'python-cinderclient',
    'python-glanceclient',
    'python-neutronclient',
    'python-heatclient' ]:
      ensure   => installed,
      provider => pip,
    }
  }

  class { 'desktop::atom':
    user         => $user,
    install_atom => $install_atom,
  }

  # i3wm
  if $install_i3 {
    if $operatingsystem == "CentOS" {
      exec { 'yum-groupinstall-x':
        command => 'yum groupinstall -y "X Window System" "Desktop" "Desktop Platform"',
        path    => '/usr/bin',
        creates => '/usr/bin/startx',
      }
    }

    vcsrepo { "/home/${user}/.powerline-fonts-install":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/powerline/fonts.git',
      owner    => $user,
      group    => $user,
    }
    ~> exec { 'powerline-fonts-install':
      command     => 'install.sh',
      path        => "/home/${user}/.powerline-fonts-install",
      user        => $user,
      refreshonly => true,
    }

    if $operatingsystem == "CentOS" {
      yumrepo { 'admiralnemo-i3wm-el7':
        ensure  => present,
        baseurl => 'https://copr-be.cloud.fedoraproject.org/results/admiralnemo/i3wm-el7/epel-7-$basearch/',
        gpgkey  => 'https://copr-be.cloud.fedoraproject.org/results/admiralnemo/i3wm-el7/pubkey.gpg',
      }
      ->package { [ 'nautilus',
      'thunderbird',
      'terminator',
      'evince',
      'lightdm',
      'liberation-mono-fonts',
      'dejavu-sans-fonts',
      'dejavu-sans-mono-fonts',
      'dejavu-serif-fonts',
      'i3',
      'i3status',
      'feh',
      'vim-X11',
      'xsel' ]:
        ensure => installed,
      }
    } else {
      package { [ 'i3', 'lightdm', 'feh', 'terminator' ]:
        ensure => installed,
      }
    }

    file { "/home/${user}/.config/i3":
      ensure => directory,
      owner  => $user,
      group  => $user,
    }
    file { 'i3config':
      ensure  => file,
      path    => "/home/${user}/.config/i3/config",
      replace => false,
      owner   => $user,
      group   => $user,
      source  => 'puppet:///modules/desktop/i3config',
    }
    file { 'dotgvimrc':
      ensure  => file,
      path    => "/home/${user}/.gvimrc",
      replace => false,
      owner   => $user,
      group   => $user,
      source  => 'puppet:///modules/desktop/dotgvimrc',
    }

    class { 'desktop::chrome':
      user             => $user,
      install_chrome   => $install_chrome,
      chrome_bookmarks => $chrome_bookmarks,
    }

    # set system to boot to graphical mode
    if $operatingsystem == "CentOS" {
      exec { 'systemctl-set-default-graphical':
        command => 'systemctl set-default graphical.target',
        path    => '/usr/bin',
        unless  => 'systemctl get-default | grep graphical.target',
        notify  => Exec['systemctl-isolate-graphical'],
        require => Package['lightdm'],
      }
      exec { 'systemctl-isolate-graphical':
        command     => 'systemctl isolate graphical.target',
        path        => '/usr/bin',
        refreshonly => true,
        require     => Package['lightdm'],
      }
    }
  }

  # passwordsafe
  class { 'desktop::passwordsafe':
    user            => $user,
    install_passwordsafe => $install_passwordsafe,
  }

  # mplayer
  class { 'desktop::mplayer':
    user            => $user,
    install_mplayer => $install_mplayer,
  }

  # lilyterm
  class { 'desktop::lilyterm':
    user            => $user,
    custom_lilyterm => $custom_lilyterm,
  }

  # xrdp
  if $install_xrdp {
    unless $install_i3 {
      fail('X Windows must be installed before using xrdp')
    }

    package { 'xrdp':
      ensure  => installed,
    }
    ->service { 'xrdp':
      ensure => running,
      enable => true,
    }
    file { "/home/${user}/.Xclients":
      ensure  => file,
      owner   => $user,
      group   => $user,
      mode    => '0755',
      content => 'i3',
    }
  }
}
