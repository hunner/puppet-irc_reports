require 'puppet'
require 'yaml'
require 'json'
require 'uri'
require 'net/https'

unless Puppet.version >= '2.6.5'
  fail "This report processor requires Puppet version 2.6.5 or later"
end

Puppet::Reports.register_report(:irc) do
  configfile = File.join([File.dirname(Puppet.settings[:config]), "irc.yaml"])
  raise(Puppet::ParseError, "IRC report config file #{configfile} not readable") unless File.exist?(configfile)
  CONFIG = YAML.load_file(configfile)

  desc <<-DESC
  Send notification of failed reports to an IRC channel and if configured create a Gist with the log output.
  DESC

  def process
    if self.status == 'failed'
      output = []
      self.logs.each do |log|
        output << log
      end
      if self.environment.nil?
        self.environment == 'production'
      end
      if CONFIG[:github_user] && CONFIG[:github_password]
        gist_id = gist(self.host,output)
        message = "Puppet #{self.environment} run for #{self.host} #{self.status} at #{Time.now.asctime}. Created a Gist showing the output at #{gist_id}"
      else
        Puppet.info "No GitHub credentials provided in irc.yaml - cannot create Gist with log output."
        message = "Puppet #{self.environment} run for #{self.host} #{self.status} at #{Time.now.asctime}."
      end

      max_attempts = 2
      begin
        timeout(8) do
          Puppet.debug "Sending status for #{self.host} to IRC."
          uri = URI.parse(CONFIG[:irc_server])
          params  = {
            :server  => CONFIG[:server],
            :nick    => CONFIG[:nick],
            :channel => CONFIG[:channel],
            :ssl     => CONFIG[:irc_ssl] || false,
            :message => message,
          }
          params[:server_password] = CONFIG[:server_password] if CONFIG.has_key?(:server_password)
          params[:channel_password] = CONFIG[:channel_password] if CONFIG.has_key?(:channel_password)
          params[:port] = CONFIG[:port] if CONFIG.has_key?(:port)
          IRC.msg(params)
        end
      rescue Timeout::Error
         Puppet.notice "Failed to send report to #{CONFIG[:irc_server]} retrying..."
         max_attempts -= 1
         if max_attempts > 0
           retry
         else
           Puppet.err "Failed to send report to #{CONFIG[:irc_server]}"
         end
      end
    end
  end

  def gist(host,output)
    max_attempts = 2
    begin
      timeout(8) do
        https = Net::HTTP.new('api.github.com', 443)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https.start {
          req = Net::HTTP::Post.new('/gists')
          req.basic_auth "#{CONFIG[:github_user]}", "#{CONFIG[:github_password]}"
          req.content_type = 'application/json'
          req.body = JSON.dump({
            "files" => { "#{host}-#{Time.now.to_i.to_s}" => { "content" => output.join("\n") } },
            "description" => "Puppet #{environment} run failed on #{host} @ #{Time.now.asctime}",
            "public" => false
          })
          response = https.request(req)
          gist_id = JSON.parse(response.body)["html_url"]
        }
      end
    rescue Timeout::Error
      Puppet.notice "Timed out while attempting to create a GitHub Gist, retrying ..."
      max_attempts -= 1
      if max_attempts > 0
        retry
      else
        Puppet.err "Timed out while attempting to create a GitHub Gist."
      end
    end
  end
end

class IRC
  def initialize(params)
    port = params[:port] || (params[:ssl] ? "6697" : "6667")
    if params[:ssl]
      @irc = TCPSocket.open(params[:server], port)
    else
      context = OpenSSL::SSL::SSLContext.new()
      @irc = OpenSSL::SSL::SSLSocket.new(TCPSocket.new(params[:server], port), context).connect
    end
    @irc.puts "PASS #{params[:server_password]}" if params[:server_password]
    @irc.puts "USER #{params[:nick]} 0 * :#{params[:nick]}"
    @irc.puts "NICK #{params[:nick]}"
    sleep 1 until connection.gets =~ /001/
    @irc.puts "JOIN #{params[:channel]} #{params[:channel_password]}"
  end
  def msg(params)
    IRC.new(params) unless @irc
    @irc.puts "PRIVMSG #{params[:channel]} :#{params[:message]}"
  end
end
