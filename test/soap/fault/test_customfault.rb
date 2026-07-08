# encoding: UTF-8
require 'helper'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'


module SOAP
module Fault


class TestCustomFault < Test::Unit::TestCase
  Port = 17171

  class CustomFaultServer < SOAP::RPC::StandaloneServer
    def on_init
      add_method(self, 'fault', 'msg')
    end

    def fault(msg)
      SOAPFault.new(SOAPString.new("mycustom"),
        SOAPString.new("error: #{msg}"),
        SOAPString.new(self.class.name))
    end
  end

  def setup
    @server = CustomFaultServer.new('customfault', 'urn:customfault', '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @t = TestUtil.start_server_thread(@server)
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint, 'urn:customfault')
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method("fault", "msg")
  end

  def teardown
    @server.shutdown if @server
    if @t
      # join with a bound, falling back to kill only if genuinely
      # stuck (see git history: unconditional immediate kill raced
      # WEBrick's own async listener cleanup and occasionally leaked
      # the port).
      unless @t.join(10)
        @t.kill
        @t.join
      end
    end
    @client.reset_stream if @client
  end

  def test_custom_fault
    begin
      @client.fault("message")
      assert(false, 'exception not raised')
    rescue SOAP::FaultError => e
      assert(true, 'exception raised')
      assert_equal('error: message', e.message)
    end
  end
end


end
end
