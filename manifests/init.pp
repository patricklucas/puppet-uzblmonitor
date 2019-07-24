# == Class: uzblmonitor
#
# Full description of class uzblmonitor here.
#
# === Parameters
#
# Document parameters here.
#
# [*example_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
# === Variables
#
# List of variables this module requires and uses.
#
# [*example_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default.
#
# === Examples
#
#  class { 'uzblmonitor':
#  # ...
#  }
#
class uzblmonitor(
  $browser = 'google-chrome-stable'
) {

  $quoted_browser = shellquote($browser)

  # Remove stock-Ubuntu DM packages
  package { ['lightdm', 'ubuntu-session', 'unity', 'unity-greeter']:
    ensure => purged,
  } ->
  # Install NoDM and Matchbox for kiosk-style display/window management
  # x11-utils for resolution detection in the python script
  package { ['xserver-xorg', 'xserver-xorg-core', 'nodm', 'matchbox-window-manager', 'xnest', 'xterm', 'x11-utils']:
    ensure => latest,
  }

  package { 'browser-plugin-gnash':
    ensure => latest,
  }

  package { 'unclutter':
    ensure => latest,
  }

  user { 'monitor':
    ensure     => present,
    managehome => true,
    groups     => ['audio', 'video']
  } ->
  file { '/home/monitor/.xsession':
    ensure => file,
    owner  => monitor,
    group  => monitor,
    mode   => '0444',
    source => 'puppet:///modules/uzblmonitor/xsession',
  }
  if $::systemd {
    systemd::unit_file { 'nodm-uzblmonitor.service':
      content =>  template('uzblmonitor/nodm-uzblmonitor.service.erb')
    }
  } else {

    file { '/etc/init/nodm-uzblmonitor.conf':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0444',
      source => 'puppet:///modules/uzblmonitor/nodm-uzblmonitor.conf',
    } ->
    file { '/etc/default/nodm-uzblmonitor':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0444',
      source => 'puppet:///modules/uzblmonitor/nodm-uzblmonitor.default',
    }
  }

  service { 'nodm-uzblmonitor':
    enable  => true,
    ensure  => running,
    require => Package['nodm'],
  }

  package { 'uzblmonitor_browser_package':
    name => $browser,
    ensure => latest,
  } ->
  file { '/usr/bin/uzblmonitor':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/uzblmonitor/uzblmonitor',
  }
  if $::systemd {
    systemd::unit_file { 'uzblmonitor.service':
      content =>  template('uzblmonitor/uzblmonitor.service.erb')
    }
  } else {
    file { '/etc/default/uzblmonitor':
      content => "BROWSER=${quoted_browser}",
      notify => Service['uzblmonitor'],
    } ->
    file { '/etc/init/uzblmonitor.conf':
      ensure => file,
      owner  => root,
      group  => root,
      mode   => '0444',
      source => 'puppet:///modules/uzblmonitor/uzblmonitor.conf',
    }
  }
  service { 'uzblmonitor':
    enable  => true,
    ensure  => running,
    require => Service['nodm-uzblmonitor'],
  }

  if $browser == 'luakit' {
    file { '/etc/xdg/luakit/uzblmonitor.lua':
      source => 'puppet:///modules/uzblmonitor/uzblmonitor.lua',
    }
  }
}
