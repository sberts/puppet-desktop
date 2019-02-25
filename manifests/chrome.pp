# chrome
#
class desktop::chrome(
  String $user            = 'ec2-user',
  Boolean $install_chrome = true,
  Array $chrome_bookmarks = [],
) {
  if $install_chrome {
    if $::operatingsystem == 'CentOS' {
      yumrepo { 'google-chrome':
        ensure  => present,
        baseurl => 'http://dl.google.com/linux/chrome/rpm/stable/x86_64',
        gpgkey  => 'https://dl.google.com/linux/linux_signing_key.pub',
      }
      ->package { 'google-chrome':
        ensure => installed,
      }
      $browsername = 'google-chrome-unstable'
    } else {
      package { 'chromium-browser':
        ensure => installed,
      }
      $browsername = 'chromium'
      file { "/home/${user}/bin/google.sh":
        ensure => file,
        owner  => $user,
        group  => $user,
        source => 'puppet:///modules/desktop/google.sh',
        mode   => '0755'
      }
    }
    file { '/usr/local/bin/add-bookmarks.py':
      ensure => file,
      mode   => '0755',
      owner  => root,
      group  => root,
      source => 'puppet:///modules/desktop/add-bookmarks.py',
    }

    $bookmarksfile = "/home/${user}/.config/${browsername}/Default/Bookmarks"
    $urlfile = "/home/${user}/.bookmarks-urls"

    file { [ "/home/${user}/.config",
    "/home/${user}/.config/${browsername}",
    "/home/${user}/.config/${browsername}/Default" ]:
      ensure => directory,
      owner  => $user,
      group  => $user,
    }
    ->file { $bookmarksfile:
      ensure  => file,
      owner   => $user,
      group   => $user,
      replace => false,
      source  => 'puppet:///modules/desktop/Bookmarks',
      notify  => Exec['add-bookmarks'],
    }

    file { $urlfile:
      ensure  => file,
      owner   => $user,
      group   => $user,
      content => inline_template('<% @chrome_bookmarks.each do |url| %><%= "#{url}\r\n" %><% end %>'),
      notify  => Exec['add-bookmarks'],
    }

    exec { 'add-bookmarks':
      command     => "add-bookmarks.py ${bookmarksfile} ${urlfile}",
      refreshonly => true,
      path        => '/usr/local/bin',
      user        => $user,
      require     => [ File['/usr/local/bin/add-bookmarks.py'], File[$bookmarksfile] ],
    }
  }
}
