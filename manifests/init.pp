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
  include ::httpd::mod::wsgi
  include ::pip

  package { 'django':
    ensure   => '1.4',
    provider => openstack_pip,
  }
  package { 'python-openid':
    ensure   => present,
    provider => openstack_pip,
  }
  package { 'django-openid-auth':
    ensure   => present,
    provider => openstack_pip,
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

  # for the local wsgi app
  file { '/var/www/odsreg':
    ensure => directory,
    mode   => '0755',
  }

  # for our data storage
  file { '/var/lib/odsreg':
    ensure => directory,
    mode   => '0755',
    owner  => 'www-data',
  }

  # a plain git checkout
  vcsrepo { '/opt/odsreg':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://git.openstack.org/openstack-infra/odsreg',
  }

  file { '/usr/local/odsreg':
    ensure    => directory,
  }

  # "install" a copy of it
  file { '/usr/local/odsreg/odsreg':
    ensure    => directory,
    owner     => 'root',
    group     => 'root',
    source    => '/opt/odsreg',
    subscribe => Vcsrepo['/opt/odsreg'],
    recurse   => true,
  }

  file { '/usr/local/odsreg/local_settings.py':
    ensure  => present,
    content => template('odsreg/local_settings.py.erb'),
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
  }

  exec { 'odsreg_sync_db':
    user    => 'www-data',
    command => 'python /usr/local/odsreg/odsreg/manage.py syncdb --noinput',
    cwd     => '/usr/local/odsreg',
    path    => '/bin:/usr/bin',
    onlyif  => 'test ! -f /var/lib/odsreg/summit.db',
    require => [
      File['/usr/local/odsreg/local_settings.py'],
      File['/var/lib/odsreg'],
    ],
  }

  file { '/var/www/odsreg/django.wsgi':
    ensure => present,
    source => 'puppet:///modules/odsreg/django.wsgi',
    mode   => '0555',
    owner  => 'root',
    group  => 'root',
  }

  ::httpd::vhost { $vhost_name:
    port     => 80,
    priority => '50',
    docroot  => 'MEANINGLESS_ARGUMENT',
    template => 'odsreg/odsreg.vhost.erb',
  }

}
