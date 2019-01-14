# lilyterm
#
class desktop::lilyterm(
  String $user             = 'ec2-user',
  Integer $display_width   = 1920,
  Boolean $custom_lilyterm = true,
) {
  if $operatingsystem == "CentOS" {
    package { 'lilyterm':
      ensure => present,
    }
  } else {
    package { [ 'libvte-dev', 'intltool' ]:
      ensure => present,
    }
  }

  if $custom_lilyterm {
    file { "/home/${user}/.config/lilyterm":
      ensure => directory,
      owner  => $user,
      group  => $user,
    }
    file { "/home/${user}/.config/lilyterm/default.conf":
      ensure => file,
      owner  => $user,
      group  => $user,
      source => 'puppet:///modules/desktop/default.conf',
    }
    if $operatingsystem == "CentOS" {
      $imagemagickpackage = 'ImageMagick'
    } else {
      $imagemagickpackage = 'imagemagick'
    }
    package { $imagemagickpackage:
      ensure => installed,
    }
    file { "/home/${user}/bin":
      ensure => directory,
      owner  => $user,
      group  => $user,
    }
    file { "/home/${user}/bin/lterm.sh":
      ensure => file,
      mode   => '0755',
      owner  => $user,
      group  => $user,
      source => 'puppet:///modules/desktop/lterm.sh',
    }
    file { "/home/${user}/bin/ltermconf.sh":
      ensure => file,
      mode   => '0755',
      owner  => $user,
      group  => $user,
      source => 'puppet:///modules/desktop/ltermconf.sh',
    }
    file { "/home/${user}/bin/resizewp.sh":
      ensure => file,
      mode   => '0755',
      owner  => $user,
      group  => $user,
      source => 'puppet:///modules/desktop/resizewp.sh',
    }
    file { "/home/${user}/.wallpaper.tar.gz":
      ensure => file,
      mode   => '0660',
      owner  => $user,
      group  => $user,
      source => 'puppet:///modules/desktop/wallpaper.tar.gz',
    }
    ~>exec { 'untar-wallpaper':
      command     => 'tar -zxf .wallpaper.tar.gz',
      cwd         => "/home/${user}",
      path        => '/bin:/usr/bin',
      refreshonly => true,
    }
    ~>exec { 'resize-wallpaper':
      command     => "resizewp.sh ${display_width}",
      cwd         => "/home/${user}/wallpaper",
      path        => "/home/${user}/bin",
      refreshonly => true,
      require     => Package[$imagemagickpackage],
    }
    ~>exec { 'lilyterm-conf':
      command     => "ltermconf.sh ${user}",
      cwd         => "/home/${user}/.config/lilyterm",
      path        => "/home/${user}/bin",
      refreshonly => true,
      require     => File["/home/${user}/.config/lilyterm/default.conf"],
    }
  }
}
