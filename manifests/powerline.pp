# powerline
#
class desktop::powerline(
  String $user = 'ec2-user',
  Boolean $install_powerline = true,
) {
  if $install_powerline {
    $powerline_path = '/usr/local/lib/python3.8/dist-packages/powerline'

    package { 'powerline-status':
      ensure   => installed,
      provider => pip3,
    }

    file { "${powerline_path}/config_files/colorschemes/shell/default.json":
      ensure => file,
      owner  => root,
      group  => root,
      source => 'puppet:///modules/desktop/powerline-colorschemes.json',
    }

    file { "${powerline_path}/config_files/themes/shell/default.json":
      ensure => file,
      owner  => root,
      group  => root,
      source => 'puppet:///modules/desktop/powerline-themes.json',
    }

    file { "/root/.tmux.conf":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0600',
      replace => false,
    }
    ->file_line { 'root-tmuxconf-powerline':
      path  => "/root/.tmux.conf",
      line  => "source \"${powerline_path}/bindings/tmux/powerline.conf\"",
      match => 'powerline.conf',
    }
  
    file { "/home/${user}/.tmux.conf":
      ensure  => file,
      owner   => $user,
      group   => $user,
      mode    => '0600',
      replace => false,
    }
    ->file_line { 'tmuxconf-powerline':
      path  => "/home/${user}/.tmux.conf",
      line  => "source \"${powerline_path}/bindings/tmux/powerline.conf\"",
      match => 'powerline.conf',
    }
  
    file_line { 'bashrc-powerline-daemon':
      path => "/home/${user}/.bashrc",
      line  => "/usr/local/bin/powerline-daemon -q",
    }
  
    file_line { 'root-bashrc-powerline':
      path  => '/root/.bashrc',
      line  => ". ${powerline_path}/bindings/bash/powerline.sh",
      match => 'powerline.sh',
    }
  
    file_line { 'bashrc-powerline':
      path => "/home/${user}/.bashrc",
      line => ". ${powerline_path}/bindings/bash/powerline.sh",
    }

    package { 'powerline-gitstatus':
      ensure   => installed,
      provider => pip3,
    }

  }
}
