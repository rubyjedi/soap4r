# encoding: UTF-8
require 'helper'
require 'testutil'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'


module SOAP


# Phase 3 of SOAP 1.2 support: full live HTTP round trip (client driver
# -> real WEBrick standalone server -> back) under soap_version =
# SOAPVersion1_2 on both ends -- proves setup_req's Content-Type action
# fallback (soaplet.rb) actually dispatches correctly with a real HTTP
# stack involved, not just that the pieces compile.
class TestSoap12HttpRoundtrip < Test::Unit::TestCase
  Port = 17171

  class EchoServer < SOAP::RPC::StandaloneServer
    def on_init
      add_method(self, 'echo', 'msg')
    end

    def echo(msg)
      msg
    end
  end

  def setup
    @server = EchoServer.new('soap12echo', 'urn:soap12echo', '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server.soap_version = SOAP::SOAPVersion1_2
    @t = TestUtil.start_server_thread(@server)
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint, 'urn:soap12echo')
    @client.soap_version = SOAP::SOAPVersion1_2
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method("echo", "msg")
  end

  def teardown
    @server.shutdown if @server
    if @t
      unless @t.join(10)
        @t.kill
        @t.join
      end
    end
    @client.reset_stream if @client
  end

  def test_soap12_round_trip_dispatches_via_content_type_action
    assert_equal("hello", @client.echo("hello"))
  end
end


end
