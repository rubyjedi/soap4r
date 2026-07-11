# encoding: UTF-8
require 'helper'
require 'soap/httpconfigloader'
require 'soap/rpc/driver'

module SOAP


class TestHTTPConfigLoader < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    @client = SOAP::RPC::Driver.new(nil, nil)
  end

  class Request
    class Header
      attr_reader :request_uri
      def initialize(request_uri)
        @request_uri = request_uri
      end
    end

    attr_reader :header
    def initialize(request_uri)
      @header = Header.new(request_uri)
    end
  end

  def test_property
    # Assertions below (h.www_auth.basic_auth) assume httpclient's specific
    # client shape, so this must check the ACTIVE backend (SOAP4R_HTTP_CLIENTS
    # can force a different one -- see lib/soap/httpbackend.rb), not merely
    # whether the gem happens to be loaded in this process (e.g.
    # test/soap/ssl/test_ssl.rb requires it unconditionally regardless of the
    # active backend). Unlike this class's other tests (which exercise
    # HTTPConfigLoader.set_options against plain fakes and don't care which
    # backend is active), this one drives a real SOAP::RPC::Driver end to end.
    unless defined?(HTTPClient) and SOAP::HTTPStreamHandler::Client == HTTPClient
      return
    end
    testpropertyname = File.join(DIR, 'soapclient.properties')
    File.open(testpropertyname, "w") do |f|
      f<<<<__EOP__
protocol.http.proxy = http://myproxy:8080
protocol.http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_PEER
# depth: 1 causes an error (intentional)
protocol.http.ssl_config.verify_depth = 1
protocol.http.ssl_config.ciphers = ALL
protocol.http.basic_auth.1.url = http://www.example.com/foo1/
protocol.http.basic_auth.1.userid = user1
protocol.http.basic_auth.1.password = password1
protocol.http.basic_auth.2.url = http://www.example.com/foo2/
protocol.http.basic_auth.2.userid = user2
protocol.http.basic_auth.2.password = password2
__EOP__
    end
    begin
      @client.loadproperty(testpropertyname)
      assert_equal('ALL', @client.options['protocol.http.ssl_config.ciphers'])
      @client.options['protocol.http.basic_auth'] <<
        ['http://www.example.com/foo3/', 'user3', 'password3']
      h = @client.streamhandler.client
      basic_auth = h.www_auth.basic_auth
      cred1 = ["user1:password1"].pack('m').tr("\n", '')
      cred2 = ["user2:password2"].pack('m').tr("\n", '')
      cred3 = ["user3:password3"].pack('m').tr("\n", '')
      basic_auth.challenge(URI.parse("http://www.example.com/"), nil)
      assert_equal(cred1, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo1/baz"))))
      assert_equal(cred2, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo2/"))))
      assert_equal(cred3, basic_auth.get(Request.new(URI.parse("http://www.example.com/foo3/baz/qux"))))
    ensure
      File.unlink(testpropertyname)  if File.file?(testpropertyname)
    end
  end

  # Regression test for the stale-bundled-CA-snapshot issue: httpclient's
  # SSLConfig doesn't trust the system CA bundle unless told to, and its
  # own lazy fallback (its gem-vendored cacert.pem) can go stale relative
  # to a real server's cert chain. HTTPConfigLoader.set_options must call
  # set_default_paths on every client's ssl_config by default.
  class FakeSSLConfig
    attr_reader :default_paths_called
    attr_reader :trusted

    def initialize
      @default_paths_called = false
      @trusted = []
    end

    def set_default_paths
      @default_paths_called = true
    end

    def set_trust_ca(value)
      @trusted << value
    end
  end

  class FakeClient
    attr_accessor :proxy
    attr_accessor :no_proxy
    attr_reader :ssl_config

    def initialize
      @ssl_config = FakeSSLConfig.new
    end
  end

  def test_set_options_defaults_ssl_config_to_system_trust
    client = FakeClient.new
    SOAP::HTTPConfigLoader.set_options(client, ::SOAP::Property.new)
    assert_equal(true, client.ssl_config.default_paths_called)
  end

  def test_set_options_still_layers_explicit_ca_file_on_top_of_default
    client = FakeClient.new
    options = ::SOAP::Property.new
    options["ssl_config.ca_file"] = '/some/custom/ca.pem'
    SOAP::HTTPConfigLoader.set_options(client, options)
    assert_equal(true, client.ssl_config.default_paths_called)
    assert_equal(['/some/custom/ca.pem'], client.ssl_config.trusted)
  end
end


end
