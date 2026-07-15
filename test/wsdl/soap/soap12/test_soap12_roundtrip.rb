# encoding: UTF-8
require 'helper'
require 'testutil'
require 'wsdl/parser'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module SOAP; module T_Soap12Roundtrip


# Phase 4 of SOAP 1.2 support, the strongest test in the whole plan:
# following test_soapenc.rb's template, proves a SOAP 1.2-bound WSDL
# doesn't just parse (test_soap12_binding_parse.rb already covers that)
# but produces a driver that completes a real, wire-correct SOAP 1.2 RPC
# call end to end -- WSDLDriverFactory#create_rpc_driver must actually
# detect binding.soapbinding.soap12 and configure the resulting driver's
# soap_version accordingly (lib/soap/wsdlDriver.rb#init_driver), or this
# fails despite the WSDL parsing perfectly fine.
class TestSoap12Roundtrip < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      add_rpc_method(self, 'echo', 'msg')
      self.soap_version = ::SOAP::SOAPVersion1_2
    end

    def echo(msg)
      msg
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))
  Port = 17171

  def setup
    @server = Server.new('Test', 'urn:soap12echo', '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
    @client = nil
  end

  def teardown
    @server.shutdown if @server
    unless @server_thread.join(10)
      @server_thread.kill
      @server_thread.join
    end
    @client.reset_stream if @client
  end

  def test_soap12_bound_wsdl_drives_a_real_call
    wsdl = File.join(DIR, 'soap12.wsdl')
    factory = ::SOAP::WSDLDriverFactory.new(wsdl)
    @client = factory.create_rpc_driver
    assert_equal(::SOAP::SOAPVersion1_2, @client.soap_version)
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    ret = @client.echo("hello")
    # RPC-style single-part response wrapping is an existing, orthogonal
    # WSDL/RPC message-mapping behavior, not a SOAP 1.2 concern -- the
    # actual point of this test is everything upstream: the request made
    # it over the wire framed as SOAP 1.2 and the server correctly
    # dispatched and responded.
    assert_equal(["hello"], ret)
  end
end


end; end; end
