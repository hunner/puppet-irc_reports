require 'spec_helper'

describe 'irc_reports', :type => :class do
  context "default settings" do
    let :facts do
      { :hostname => 'mock' }
    end
    it { should contain_file("/etc/puppetlabs/puppet/irc.yaml").with(
      :content => "---\n:server: 'irc.puppetlabs.vm'\n:nick: 'puppetmaster-mock'\n:channel: '#advanced'\n"
    ) }
  end
  {
    :server           => 'test.irc',
    :server_password  => 'password',
    :port             => '7777',
    :nick             => 'test-nick',
    :channel          => '#test-channel',
    :channel_password => 'password',
    :github_user      => 'user',
    :github_password  => 'password',
  }.each do |k,v|
    context "when setting #{k.to_s} to #{v}" do
      let :params do
        { k => v }
      end
      it "should contain the setting" do
        verify_contents(subject, '/etc/puppetlabs/puppet/irc.yaml', [":#{k.to_s}: '#{v}'"])
      end
    end
  end
end
