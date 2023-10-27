# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include puppet_client
class puppet_client ( String $puppet_server = 'puppet.local' ) {

   exec { 'add puppet-release':
    command => '/usr/bin/dnf install https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
    unless  => '/usr/bin/dnf list | grep puppet-release 2> /dev/null',
  }

  package { 'puppet':
    ensure  => 'present',
    require => Exec['add puppet-release',]
  }

  file { '/etc/puppetlabs/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['puppet'],
  }

  file { '/etc/puppetlabs/puppet/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/'],
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_client/puppet.conf.erb'),
    require => File['/etc/puppetlabs/puppet/'],
    notify  => Service['puppet']
  }

  service { 'puppet':
    ensure  => 'running',
    enable  => true,
    require => [ Package['puppet'], File['/etc/puppetlabs/puppet/puppet.conf'] ],
  }
}
