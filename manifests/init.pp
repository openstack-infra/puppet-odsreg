# == Class: odsreg
#
# Full description of class odsreg here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class odsreg(
  $vhost_name = $::fqdn,
) {

  include ::httpd
  include ::pip

  package { 'django':
    provider => 'pip',
    ensure => "1.4",
  }
  package { 'python-openid':
    provider => 'pip',
    ensure => present,
  }
  package { 'django-openid-auth':
    provider => 'pip',
    ensure => present,
  }

  user { 'odsreg':
    ensure     => present,
    home       => '/home/odsreg',
    shell      => '/bin/bash',
    gid        => 'odsreg',
    managehome => true,
    require    => Group['odsreg'],
  }

  group { 'odsreg':
    ensure => present,
  }

  # for our data storage
  file { '/var/lib/odsreg':
    ensure  => directory,
    mode    => '0755',
    owner   => 'odsreg',
    group   => 'odsreg',
    require => User['odsreg'],
  }

  # a plain git checkout
  vcsrepo { '/opt/odsreg':
    ensure   => present,
    provider => git,
    #revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/odsreg',
  }

  # "install" a copy of it
  file { '/usr/local/odsreg':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    source  => '/opt/odsreg',
    subscribe   => Vcsrepo['/opt/odsreg'],
    recurse => true,
  }

  file { '/usr/local/odsreg/local_settings.py':
    ensure  => present,
    content => template('odsreg/local_settings.py.erb'),
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
  }

  exec { 'odsreg_sync_db':
    user    => 'odsreg',
    command => 'python /usr/local/odsreg/manage.py syncdb --noinput',
    cwd     => '/usr/local/odsreg',
    path    => '/bin:/usr/bin',
    onlyif  => 'test ! -f /var/lib/odsreg/summit.db',
    require => [ File['/usr/local/odsreg/local_settings.py'],
                 File['/var/lib/odsreg'], ],
  }

}