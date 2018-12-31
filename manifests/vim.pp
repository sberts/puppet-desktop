# vim
#
class desktop::vim(
  String $user         = 'ec2-user',
  Boolean $install_vim = true,
) {
  if $install_vim {
    if $::operatingsystem == 'CentOS' {
      package { 'vim-enhanced':
        ensure => present,
      }
    } else {
      package { 'vim-tiny':
        ensure => absent,
      }
      ->package { 'vim':
        ensure => installed,
      }
    }
    file { [ "/home/${user}/.vim", "/home/${user}/.vim/bundle", "/home/${user}/.vim/autoload" ]:
      ensure => directory,
      owner  => $user,
      group  => $user,
    }
    # vim pathogen
    exec { 'curl-pathogen':
      command => "curl -LSso /home/${user}/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim",
      path    => '/usr/bin',
      user    => $user,
      creates => "/home/${user}/.vim/autoload/pathogen.vim",
    }

    # vim solarized
    ->vcsrepo { "/home/${user}/.vim/bundle/vim-colors-solarized":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/altercation/vim-colors-solarized.git',
      owner    => $user,
      group    => $user,
    }

    # vim-puppet
    ->vcsrepo { "/home/${user}/.vim/bundle/puppet":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/rodjek/vim-puppet.git',
      owner    => $user,
      group    => $user,
    }
    if $::operatingsystem == "CentOS" {
      $gempackage = 'gem'
    } else {
      $gempackage = 'rubygems'
    }
    package { $gempackage:
      ensure => installed,
    }
    ->package { 'puppet-lint':
      ensure   => installed,
      provider => gem,
    }
    vcsrepo { "/home/${user}/.vim/bundle/Conque-Shell":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/vim-scripts/Conque-Shell',
      owner    => $user,
      group    => $user,
    }
    ~>exec { 'conque-git-reset':
      command     => 'git reset --hard HEAD~1',
      path        => '/usr/bin',
      cwd         => "/home/${user}/.vim/bundle/Conque-Shell",
      refreshonly => true,
    }
    vcsrepo { "/home/${user}/.vim/bundle/vim-indent-guides":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/nathanaelkane/vim-indent-guides.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/ctrlp.vim":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kien/ctrlp.vim.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/syntastic":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/vim-syntastic/syntastic.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/tlib_vim":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/tomtom/tlib_vim.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/vim-addon-mw-utils":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/MarcWeber/vim-addon-mw-utils.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/vim-snipmate":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/garbas/vim-snipmate.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/vim-snippets":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/honza/vim-snippets.git',
      owner    => $user,
      group    => $user,
    }
    vcsrepo { "/home/${user}/.vim/bundle/tabular":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/godlygeek/tabular.git',
      owner    => $user,
      group    => $user,
    }

    # vimrc
    if $::operatingsystem == 'Ubuntu' {
      $vimpython = 'python3'
    } else {
      $vimpython = 'python'
    }

    file { "/home/${user}/.vimrc":
      ensure  => file,
      owner   => $user,
      group   => $user,
      mode    => '0640',
      content => template('desktop/dotvimrc.erb'),
      replace => false,
    }
  }
}
