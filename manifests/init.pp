# == Class: irc_reports
#
# A Puppet report handler for sending notifications of failed runs to IRC.
#
# === Parameters
#
# [*server*]
#   The server to which the irc bot should connect. Default `irc.puppetlabs.vm`
#
# [*server_password*]
#   The ircd password for the server to which the irc bot should connect. Optional
#
# [*port*]
#   The port which the bot should use. Default 6667 for non-ssl or 6697 for ssl
#
# [*ssl*]
#   Whether to use ssl. Default false
#
# [*nick*]
#   Nick which the bot uses. Default `puppetmaster-$hostname`
#
# [*channel*]
#   Channel to which the bot should join. Default `#advanced`
#
# [*channel_password*]
#   Channel password with which the bot should join. Optional
#
# [*github_user*]
#   Github username which should be used for gists. Optional
#
# [*github_password*]
#   Github password which should be used for gists. Optional
#
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
