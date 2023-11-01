# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include puppet_client
class puppet_client ( String $puppet_server = 'puppet.local' ) {

  package { 'puppet-release':
    ensure   => 'installed',
    source   => 'https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm',
    provider => 'rpm',
  }

  package { 'puppet':
    ensure  => 'present',
    require => Package['puppet-release'],
  }

  service { 'puppet':
    ensure  => 'running',
    enable  => true,
    require => [Package['puppet'], File['/etc/puppetlabs/puppet/puppet.conf']],
  }

  file { '/etc/puppetlabs/':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/puppetlabs/puppet/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/puppetlabs/'],
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet_client/puppet.conf.erb'),
    require => File['/etc/puppetlabs/puppet/'],
    notify  => Service['puppet'],
  }
}
