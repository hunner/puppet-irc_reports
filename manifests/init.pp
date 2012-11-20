class irc {
  file { '/etc/puppetlabs/puppet/irc.yaml':
    ensure => present,
    source => 'puppet:///modules/irc/irc.yaml',
  }
}
