# encoding: UTF-8
require 'helper'
require 'testutil'
require 'soap/rpc/driver'
require 'webrick'
require 'webrick/httpproxy'
require 'logger'


module SOAP; module Auth


class TestBasic < Test::Unit::TestCase
  Port = 17171
  ProxyPort = 17172

  def setup
    @logger = Logger.new(STDERR)
    @logger.level = Logger::Severity::FATAL
    @url = "http://localhost:#{Port}/"
    @proxyurl = "http://localhost:#{ProxyPort}/"
    @server = @proxyserver = @client = nil
    @server_thread = @proxyserver_thread = nil
    setup_server
    setup_client
  end

  def teardown
    teardown_client if @client
    teardown_proxyserver if @proxyserver
    teardown_server if @server
  end

  def setup_server
    @server = TestUtil.webrick_http_server(
      :BindAddress => "0.0.0.0",
      :Logger => @logger,
      :Port => Port,
      :AccessLog => [],
      :DocumentRoot => File.dirname(File.expand_path(__FILE__))
    )
    htpasswd = File.join(File.dirname(__FILE__), 'htpasswd')
    htpasswd_userdb = WEBrick::HTTPAuth::Htpasswd.new(htpasswd)
    @basic_auth = WEBrick::HTTPAuth::BasicAuth.new(
      :Logger => @logger,
      :Realm => 'auth',
      :UserDB => htpasswd_userdb
    )
    @server.mount(
      '/',
      WEBrick::HTTPServlet::ProcHandler.new(method(:do_server_proc).to_proc)
    )

    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_proxyserver
    @proxyserver = TestUtil.webrick_http_server(
      :BindAddress => "0.0.0.0",
      :Logger => @logger,
      :Port => ProxyPort,
      :AccessLog => []
    )
    @proxyserver_thread = TestUtil.start_server_thread(@proxyserver)
  end

  def setup_client
    @client = SOAP::RPC::Driver.new(@url, '')
    @client.add_method("do_server_proc")
  end

  def teardown_server
    @server.shutdown
    # join with a bound, falling back to kill only if the thread
    # is genuinely stuck (not as an unconditional first resort --
    # that raced WEBrick's own async listener cleanup and
    # occasionally leaked the port; see git history).
    unless @server_thread.join(10)
      @server_thread.kill
      @server_thread.join
    end
  end

  def teardown_proxyserver
    @proxyserver.shutdown
    # join with a bound, falling back to kill only if the thread
    # is genuinely stuck (not as an unconditional first resort --
    # that raced WEBrick's own async listener cleanup and
    # occasionally leaked the port; see git history).
    unless @proxyserver_thread.join(10)
      @proxyserver_thread.kill
      @proxyserver_thread.join
    end
  end

  def teardown_client
    @client.reset_stream
  end

  def do_server_proc(req, res)
    @basic_auth.authenticate(req, res)
    res['content-type'] = 'text/xml'
    res.body = <<__EOX__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:do_server_proc xmlns:n1="urn:foo" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return>OK</return>
    </n1:do_server_proc>
  </env:Body>
</env:Envelope>
__EOX__
  end

  def test_direct
    return unless auth_supported?
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.options["protocol.http.auth"] << [@url, "admin", "admin"]
    assert_equal("OK", @client.do_server_proc)
  end

  def test_proxy
    return unless auth_supported?
    setup_proxyserver
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.options["protocol.http.proxy"] = @proxyurl
    @client.options["protocol.http.auth"] << [@url, "guest", "guest"]
    assert_equal("OK", @client.do_server_proc)
  end

  private

  # SOAP::NetHttpClient#set_auth and SOAP::FaradayClient#set_auth both
  # explicitly raise NotImplementedError -- neither soap4r + net/http nor
  # soap4r + faraday (whose core has no bundled challenge-response
  # middleware) support WWW-Authenticate-style auth. This is a real,
  # permanent limitation for those backends, not a bug, so skip cleanly
  # rather than fail (see lib/soap/httpbackend.rb;
  # test_streamhandler.rb's test_basic_auth uses the same pattern).
  # SOAP::CurbClient DOES support this (libcurl negotiates the challenge
  # itself), so it's deliberately absent from this list.
  AUTH_UNSUPPORTED_BACKENDS = %w[SOAP::NetHttpClient SOAP::FaradayClient]

  def auth_supported?
    !AUTH_UNSUPPORTED_BACKENDS.include?(SOAP::HTTPStreamHandler::Client.name)
  end
end


end; end
