# encoding: UTF-8
require 'helper'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'
require 'soap/header/simplehandler'
require 'logger'
require 'webrick'
require 'rbconfig'


module SOAP
module Header


class TestAuthHeaderCGI < Test::Unit::TestCase
  # This test shuld be run after installing ruby.
  RUBYBIN = File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]
  )
  RUBYBIN << " -d" if $DEBUG

  if RUBY_VERSION.to_f >= 2.2
    # WEBrick::HTTPServlet::CGIHandler wipes the CGI child's entire ENV
    # before exec'ing it (cgi_runner.rb: `ENV.keys.each{|name| ENV.delete(name)}`,
    # standard CGI hygiene) -- so GEM_HOME/GEM_PATH/BUNDLE_GEMFILE never
    # reach the spawned script, and any gem it needs must be forwarded via
    # a raw -I load-path flag instead (bypasses RubyGems activation
    # entirely, so it's immune to the ENV wipe). logger-application always
    # needed this; webrick needs the same treatment now that Ruby 3.0+
    # demoted it from stdlib to a real gem.
    ['logger-application', 'webrick'].each do |gem_name|
      gem_spec = Gem::Specification.find { |s| s.name == gem_name }
      if gem_spec
        paths = gem_spec.respond_to?(:full_require_paths) ? gem_spec.full_require_paths : gem_spec.load_paths
        paths.each do |path|
          RUBYBIN << " -I #{path}"
        end
      end
    end
  end

  Port = 17171
  PortName = 'http://tempuri.org/authHeaderPort'
  SupportPortName = 'http://tempuri.org/authHeaderSupportPort'
  MyHeaderName = XSD::QName.new("http://tempuri.org/authHeader", "auth")

  class ClientAuthHeaderHandler < SOAP::Header::SimpleHandler
    def initialize(userid, passwd)
      super(MyHeaderName)
      @sessionid = nil
      @userid = userid
      @passwd = passwd
    end

    def on_simple_outbound
      if @sessionid
	{ "sessionid" => @sessionid }
      else
	{ "userid" => @userid, "passwd" => @passwd }
      end
    end

    def on_simple_inbound(my_header, mustunderstand)
      @sessionid = my_header["sessionid"]
    end

    def sessionid
      @sessionid
    end
  end

  def setup
    @endpoint = "http://localhost:#{Port}/"
    setup_server
    setup_client
  end

  def setup_server
    @endpoint = "http://localhost:#{Port}/server.cgi"
    logger = Logger.new(STDERR)
    logger.level = Logger::Severity::ERROR
    @server = TestUtil.webrick_http_server(
      :BindAddress => "0.0.0.0",
      :Logger => logger,
      :Port => Port,
      :AccessLog => [],
      :DocumentRoot => File.dirname(File.expand_path(__FILE__)),
      :CGIPathEnv => ENV['PATH'],
      :CGIInterpreter => RUBYBIN
    )
    @t = TestUtil.start_server_thread(@server)
  end

  def setup_client
    @client = SOAP::RPC::Driver.new(@endpoint, PortName)
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method('deposit', 'amt')
    @client.add_method('withdrawal', 'amt')
    @supportclient = SOAP::RPC::Driver.new(@endpoint, SupportPortName)
    @supportclient.add_method('delete_sessiondb')
  end

  def teardown
    @supportclient.delete_sessiondb if @supportclient
  ensure
    # Must run even if delete_sessiondb above raises (e.g. the CGI child
    # process failing to start) -- otherwise @server is orphaned still
    # listening on Port, and every later test file sharing that same fixed
    # port fails with EADDRINUSE for the rest of the run.
    teardown_server if @server
    teardown_client if @client
  end

  def teardown_server
    @server.shutdown
    @t.kill
    @t.join
  end

  def teardown_client
    @client.reset_stream
    @supportclient.reset_stream
  end

  def test_success
    h = ClientAuthHeaderHandler.new('NaHi', 'passwd')
    @client.headerhandler << h
    assert_equal("deposit 150 OK", @client.deposit(150))
    assert_equal("withdrawal 120 OK", @client.withdrawal(120))
  end

  def test_authfailure
    h = ClientAuthHeaderHandler.new('NaHi', 'pa')
    @client.headerhandler << h
    assert_raises(RuntimeError) do
      @client.deposit(150)
    end
  end
end


end
end
