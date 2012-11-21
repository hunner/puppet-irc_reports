class irc (
  $nick = "puppetmaster-${::hostname}",
) {
  file { '/etc/puppetlabs/puppet/irc.yaml':
    ensure  => present,
    content => template('irc/irc.yaml.erb'),
  }
}
