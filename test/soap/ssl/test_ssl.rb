# encoding: UTF-8
require 'helper'
require 'timeout'
begin
  require 'httpclient'
rescue LoadError
end
begin
  require 'curb'
rescue LoadError
end
begin
  require 'faraday'
rescue LoadError
end
require 'soap/rpc/driver'

# Checking defined?(HTTPClient) alone isn't enough now that the HTTP client
# backend is independently selectable (SOAP4R_HTTP_CLIENTS -- see
# lib/soap/httpbackend.rb): the requires above pull in these gems
# regardless of which backend SOAP::HTTPStreamHandler actually picked, so
# e.g. HTTPClient can be defined while SOAP::NetHttpClient (whose
# #ssl_config is always nil) is the active one. This must check the ACTIVE
# backend, not merely whether a gem happens to be loaded.
#
# httpclient, curb, and faraday (any SOAP4R_FARADAY_ADAPTER) all get real
# SSL config plumbing exercised here -- SOAP::NetHttpClient is excluded
# since it has no SSL configuration surface of its own at all (see
# lib/soap/netHttpClient.rb).
SSL_TESTABLE_BACKENDS = %w[HTTPClient SOAP::CurbClient SOAP::FaradayClient]
if SSL_TESTABLE_BACKENDS.include?(SOAP::HTTPStreamHandler::Client.name) and defined?(OpenSSL)

module SOAP; module SSL


class TestSSL < Test::Unit::TestCase
  PORT = 17171

  DIR = File.dirname(File.expand_path(__FILE__))
  require 'rbconfig'
  RUBY = File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]
  )

  def setup
    @url = "https://localhost:#{PORT}/hello"
    @serverpid = @client = nil
    @verify_callback_called = false
    setup_server
    setup_client
  end

  def teardown
    teardown_client
    teardown_server
  end

  def httpclient_backend?
    SOAP::HTTPStreamHandler::Client == HTTPClient
  end

  def faraday_backend?
    SOAP::HTTPStreamHandler::Client.name == 'SOAP::FaradayClient'
  end

  # Each backend surfaces a TLS verification/handshake failure as a
  # different exception class -- confirmed empirically against the real
  # server this file spins up, not guessed from documentation:
  #   httpclient: OpenSSL::SSL::SSLError
  #   curb:       Curl::Err::CurlError (base class for its whole SSL error
  #               family -- SSLPeerCertificateError, SSLCACertificateError,
  #               SSLCypherError, etc. -- rather than pinning to one)
  #   faraday:    Faraday::Error (SSLError and ConnectionFailed are BOTH
  #               direct subclasses of it, and different Faraday adapters
  #               raise different ones for the same failure -- confirmed
  #               :typhoeus raises ConnectionFailed, not SSLError)
  def expected_ssl_error_class
    case SOAP::HTTPStreamHandler::Client.name
    when 'SOAP::CurbClient'
      Curl::Err::CurlError
    when 'SOAP::FaradayClient'
      Faraday::Error
    else
      OpenSSL::SSL::SSLError
    end
  end

  def test_options
    return unless httpclient_backend?
    cfg = @client.streamhandler.client.ssl_config
    assert_nil(cfg.client_cert)
    assert_nil(cfg.client_key)
    assert_nil(cfg.client_ca)
    assert_equal(OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT, cfg.verify_mode)
    assert_nil(cfg.verify_callback)
    assert_nil(cfg.timeout)

    # RubyJedi:  Emulate what we expect httpclient's ssl_config initializer to be doing.
    #   (Adapted from initialize() at https://github.com/nahi/httpclient/blob/master/lib/httpclient/ssl_config.rb )
    ssl_options = OpenSSL::SSL::OP_ALL
    ssl_options &= ~OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS if defined?(OpenSSL::SSL::OP_DONT_INSERT_EMPTY_FRAGMENTS)
    ssl_options |= OpenSSL::SSL::OP_NO_COMPRESSION if defined?(OpenSSL::SSL::OP_NO_COMPRESSION)
    ssl_options |= OpenSSL::SSL::OP_NO_SSLv2 if defined?(OpenSSL::SSL::OP_NO_SSLv2)
    ssl_options |= OpenSSL::SSL::OP_NO_SSLv3 if defined?(OpenSSL::SSL::OP_NO_SSLv3)    

    assert_equal(ssl_options, cfg.options)
    assert_equal("ALL:!aNULL:!eNULL:!SSLv2", cfg.ciphers)

    assert_instance_of(OpenSSL::X509::Store, cfg.cert_store)
    # dummy call to ensure sslsvr initialization finished.
    assert_raise(OpenSSL::SSL::SSLError) do
      @client.hello_world("ssl client")
    end
  end

  # verify_callback is not portable across backends: no libcurl-based
  # backend (curb, or Faraday riding on typhoeus/patron/etc.) exposes a
  # per-certificate Ruby callback hook the way OpenSSL::SSL::SSLContext
  # does -- confirmed there's no equivalent in either library's public API.
  # See test_ca_verification below for the backend-neutral equivalent of
  # what this test covers, minus the callback-specific assertions.
  def test_verification
    return unless httpclient_backend?
    cfg = @client.options
    cfg["protocol.http.ssl_config.verify_callback"] = method(:verify_callback).to_proc
    begin
      @verify_callback_called = false
      @client.hello_world("ssl client")
      assert(false)
    rescue OpenSSL::SSL::SSLError => ssle
      assert(/certificate verify failed/ =~ ssle.message)
      assert(@verify_callback_called)
    end
    #
    cfg["protocol.http.ssl_config.client_cert"] = File.join(DIR, "client.cert")
    cfg["protocol.http.ssl_config.client_key"] = File.join(DIR, "client.key")
    @verify_callback_called = false
    begin
      @client.hello_world("ssl client")
      assert(false)
    rescue OpenSSL::SSL::SSLError => ssle
      assert(/certificate verify failed/ =~ ssle.message)
      assert(@verify_callback_called)
    end
    #
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "ca.cert")
    @verify_callback_called = false
    begin
      @client.hello_world("ssl client")
      assert(false)
    rescue OpenSSL::SSL::SSLError => ssle
      assert(/certificate verify failed/ =~ ssle.message)
      assert(@verify_callback_called)
    end
    #
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "subca.cert")
    @verify_callback_called = false
    assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
    assert(@verify_callback_called)
    #
    cfg["protocol.http.ssl_config.verify_depth"] = "0"
    @verify_callback_called = false
    begin
      @client.hello_world("ssl client")
      assert(false)
    rescue OpenSSL::SSL::SSLError => ssle
      assert(/certificate verify failed/ =~ ssle.message)
      assert(@verify_callback_called)
    end
    #
    cfg["protocol.http.ssl_config.verify_depth"] = ""
    cfg["protocol.http.ssl_config.cert_store"] = OpenSSL::X509::Store.new
    cfg["protocol.http.ssl_config.verify_mode"] = OpenSSL::SSL::VERIFY_PEER.to_s
    begin
      @client.hello_world("ssl client")
      assert(false)
    rescue OpenSSL::SSL::SSLError => ssle
      assert(/certificate verify failed/ =~ ssle.message)
    end
    #
    cfg["protocol.http.ssl_config.verify_mode"] = ""
    assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
  end

  # Also verify_callback-dependent throughout -- see test_verification above.
  def test_property
    return unless httpclient_backend?
    testpropertyname = File.join(DIR, 'soapclient.properties')
    File.open(testpropertyname, "w") do |f|
      f<<<<__EOP__
protocol.http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_PEER
protocol.http.ssl_config.verify_depth = 0
protocol.http.ssl_config.client_cert = #{File.join(DIR, 'client.cert')}
protocol.http.ssl_config.client_key = #{File.join(DIR, 'client.key')}
protocol.http.ssl_config.ca_file = #{File.join(DIR, 'ca.cert')}
protocol.http.ssl_config.ca_file = #{File.join(DIR, 'subca.cert')}
protocol.http.ssl_config.ciphers = ALL
__EOP__
    end
    begin
      @client.loadproperty(testpropertyname)
      @client.options["protocol.http.ssl_config.verify_callback"] = method(:verify_callback).to_proc
      @verify_callback_called = false
      # NG with String
      begin
        @client.hello_world("ssl client")
        assert(false)
      rescue OpenSSL::SSL::SSLError => ssle
        assert(/certificate verify failed/ =~ ssle.message)
        assert(@verify_callback_called)
      end
      # NG with Integer
      @client.options["protocol.http.ssl_config.verify_depth"] = 0
      begin
        @client.hello_world("ssl client")
        assert(false)
      rescue OpenSSL::SSL::SSLError => ssle
        assert(/certificate verify failed/ =~ ssle.message)
        assert(@verify_callback_called)
      end
      # OK with empty
      @client.options["protocol.http.ssl_config.verify_depth"] = ""
      @verify_callback_called = false
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
      assert(@verify_callback_called)
      # OK with nil
      @client.options["protocol.http.ssl_config.verify_depth"] = nil
      @verify_callback_called = false
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
      assert(@verify_callback_called)
      # OK with String
      @client.options["protocol.http.ssl_config.verify_depth"] = "3"
      @verify_callback_called = false
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
      assert(@verify_callback_called)
      # OK with Integer
      @client.options["protocol.http.ssl_config.verify_depth"] = 3
      @verify_callback_called = false
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
      assert(@verify_callback_called)
    ensure
      File.unlink(testpropertyname) if File.file?(testpropertyname)
    end
  end

  def test_ciphers
    cfg = @client.options
    cfg["protocol.http.ssl_config.client_cert"] = File.join(DIR, 'client.cert')
    cfg["protocol.http.ssl_config.client_key"] = File.join(DIR, 'client.key')
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "ca.cert")
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "subca.cert")
    #cfg.timeout = 123
    cfg["protocol.http.ssl_config.ciphers"] = "!ALL"
    #
    if faraday_backend?
      # Confirmed empirically: Faraday's own :typhoeus adapter never
      # forwards Faraday::SSLOptions#ciphers to ethon's ssl_cipher_list at
      # all, so "!ALL" is silently ignored rather than rejected -- a real
      # gap in that third-party adapter (not this bridge, and not
      # something soap4r-ng's own code can fix). The handshake succeeds
      # here regardless of the (unhonored) cipher restriction.
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
    else
      begin
        @client.hello_world("ssl client")
        assert(false)
      rescue expected_ssl_error_class => ssle
        if httpclient_backend?
          # depends on OpenSSL version. (?:0.9.8|0.9.7)
          assert_match(/\A(?:SSL_CTX_set_cipher_list:+ no cipher match|no ciphers available)\z/, ssle.message)
        end
        # curb's own message ("Could not use specified SSL cipher: failed
        # setting cipher list: !ALL") is asserted only by class above --
        # its exact wording isn't pinned since it's libcurl/OpenSSL-version
        # dependent the same way httpclient's is.
      end
    end
    #
    cfg["protocol.http.ssl_config.ciphers"] = "ALL"
    assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
  end

  # Backend-neutral equivalent of test_verification/test_property, minus
  # the verify_callback-specific assertions those can't support on
  # anything but httpclient (see the comment on test_verification). This
  # is what actually matters for "does soap4r-ng's own config-loading
  # bridge correctly plumb ca_file/client_cert/client_key through to a real
  # TLS handshake" -- runs identically for every SSL-testable backend.
  def test_ca_verification
    cfg = @client.options
    cfg["protocol.http.ssl_config.client_cert"] = File.join(DIR, "client.cert")
    cfg["protocol.http.ssl_config.client_key"] = File.join(DIR, "client.key")
    #
    # No ca_file configured at all -- client has no reason to trust this
    # private test CA, so verification must fail regardless of backend.
    assert_ssl_verification_fails { @client.hello_world("ssl client") }
    #
    # Wrong CA (the root, not the intermediate that actually signed the
    # server's cert) -- still fails.
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "ca.cert")
    assert_ssl_verification_fails { @client.hello_world("ssl client") }
    #
    # Correct CA (the signing intermediate) -- succeeds.
    cfg["protocol.http.ssl_config.ca_file"] = File.join(DIR, "subca.cert")
    assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
  end

  # test-unit's assert_raise wants an EXACT class match, not
  # kind_of?/subclass-inclusive like plain Ruby rescue -- confirmed
  # empirically (curb/Faraday both raise a specific subclass of the base
  # class expected_ssl_error_class returns, e.g. Curl::Err::SSLPeerCertificateError
  # rather than bare Curl::Err::CurlError, and assert_raise rejected it).
  # Every other SSL-exception check in this file already routes around
  # that via begin/rescue instead of assert_raise; this just gives
  # test_ca_verification the same treatment.
  def assert_ssl_verification_fails
    yield
    assert(false, "expected an SSL verification failure")
  rescue expected_ssl_error_class
  end

private

  def setup_server
    # No quoting around RUBY here: on POSIX, IO.popen only spawns an
    # intermediary /bin/sh -c when the command string contains shell
    # metacharacters. Quoting was doing exactly that (unnecessarily, since
    # RbConfig's bindir path never has embedded whitespace), which made
    # svrout.pid the *shell's* pid rather than sslsvr.rb's -- so the pid
    # sslsvr.rb reports over stdout (its own $$) was a grandchild, not a
    # direct child, and teardown_server's Process.waitpid below always
    # failed with Errno::ECHILD (100% of the time, on every run). Dropping
    # the quotes lets Ruby exec directly with no shell hop, so the reported
    # pid is a real, waitable child again.
    svrcmd = "#{RUBY} "
    svrcmd << File.join(DIR, "sslsvr.rb")
    svrout = IO.popen(svrcmd)
    # sslsvr.rb only prints its PID once its own WEBrick server has bound
    # successfully (which retries internally on EADDRINUSE -- see
    # lib/soap/rpc/httpserver.rb#new_webrick_server). Without a timeout here,
    # a stuck child means this blocking read hangs indefinitely with zero
    # console output -- confirmed via a local repro (pre-occupying port 17171
    # made this block for the full retry window with nothing printed at all,
    # looking exactly like the silent CI hangs seen in run 28892185757).
    # Bounded slightly above that retry window so it only fires as a genuine
    # backstop, not under normal contention.
    line = nil
    begin
      Timeout.timeout(130) { line = svrout.gets }
    rescue Timeout::Error
      Process.kill('KILL', svrout.pid) rescue nil
      Process.waitpid(svrout.pid) rescue nil
      raise "sslsvr.rb did not report its PID within 130s -- likely stuck retrying its own port bind"
    end
    raise "sslsvr.rb exited without printing a PID (crashed before starting?)" if line.nil?
    @serverpid = Integer(line.chomp)
  end

  def setup_client
    @client = SOAP::RPC::Driver.new(@url, 'urn:ssltst')
    @client.add_method("hello_world", "from")
  end

  def teardown_server
    if @serverpid
      Process.kill('KILL', @serverpid)
      begin
        Process.waitpid(@serverpid)
      rescue
        $stderr.puts "WARNING: Attempted to tear down server, but no Child Process found to wait on?"
        sleep 5 # Hopefully give enough time for the system to release the Socket that the quickly-killed child process had
      end
    end
  end

  def teardown_client
    @client.reset_stream if @client
  end

  def verify_callback(ok, cert)
    @verify_callback_called = true
    p ["client", ok, cert] if $DEBUG
    ok
  end
end


end; end

end
