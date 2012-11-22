class irc_reports (
  $server           = 'irc.puppetlabs.vm',
  $server_password  = undef,
  $port             = undef,
  $ssl              = undef,
  $nick             = "puppetmaster-${::hostname}",
  $channel          = '#advanced',
  $channel_password = undef,
  $github_user      = undef,
  $github_password  = undef,
) {
  # Template uses all parameters
  file { '/etc/puppetlabs/puppet/irc.yaml':
    ensure  => present,
    content => template('irc_reports/irc.yaml.erb'),
  }
}
