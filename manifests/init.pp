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
class uzblmonitor {

  # Remove stock-Ubuntu DM packages
  package { ["lightdm", "ubuntu-session", "unity", "unity-greeter"]:
    ensure => purged,
  } ->
  # Install NoDM and Matchbox for kiosk-style display/window management
  package { ["xserver-xorg", "nodm", "matchbox-window-manager"]:
    ensure => installed,
  }

  user { 'monitor':
    ensure     => present,
    managehome => true,
  } ->
  file { '/home/monitor/.xsession':
    ensure  => file,
    owner   => monitor,
    group   => monitor,
    mode    => 0444,
    content => '#!/bin/bash\nexec matchbox-window-manager -use_titlebar no\n',
  } ->
  file { '/etc/init/nodm-uzblmonitor.conf':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0444,
    source => 'puppet:///modules/uzblmonitor/nodm-uzblmonitor.conf',
  } ->
  file { '/etc/default/nodm-uzblmonitor':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0444,
    source => 'puppet:///modules/uzblmonitor/nodm-uzblmonitor.default',
  } ->
  service { 'nodm-uzblmonitor':
    ensure  => running,
    require => Package['nodm'],
  }

  package { 'uzbl':
    ensure => installed,
  } ->
  file { '/usr/bin/uzblmonitor':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0755,
    source => 'puppet:///modules/uzblmonitor/uzblmonitor',
  } ->
  file { '/etc/init/uzblmonitor.conf':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => 0444,
    source => 'puppet:///modules/uzblmonitor/uzblmonitor.conf',
  } ->
  service { 'uzblmonitor':
    ensure  => running,
    require => Service['nodm-uzblmonitor'],
  }

}
