require 'test/unit'
require 'soap/httpconfigloader'
require 'soap/rpc/driver'


module SOAP


class TestHTTPConfigLoader < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def setup
    @client = SOAP::RPC::Driver.new(nil, nil)
  end

  def test_property
    testpropertyname = File.join(DIR, 'soapclient.properties')
    File.open(testpropertyname, "w") do |f|
      f <<<<__EOP__
protocol.http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_PEER
# depth: 1 causes an error (intentional)
protocol.http.ssl_config.verify_depth = 1
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
      begin
        @client.hello_world("ssl client")
        assert(false)
      rescue OpenSSL::SSL::SSLError => ssle
        assert_equal("certificate verify failed", ssle.message)
        assert(@verify_callback_called)
      end
      #
      @client.options["protocol.http.ssl_config.verify_depth"] = ""
      @verify_callback_called = false
      assert_equal("Hello World, from ssl client", @client.hello_world("ssl client"))
      assert(@verify_callback_called)
    ensure
      File.unlink(testpropertyname)
    end
  end
end


end
