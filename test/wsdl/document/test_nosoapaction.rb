# encoding: UTF-8
require 'helper'
require 'testutil'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require 'soap/rpc/driver'


module WSDL; module Document


class TestNoSOAPAction < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'http://xmlsoap.org/Ping'

    def on_init
      add_document_method(
        self,
        Namespace + '/ping',
        'ping_with_soapaction',
        XSD::QName.new(Namespace, 'Ping'),
        XSD::QName.new(Namespace, 'PingResponse')
      )

      add_document_method(
        self,
        nil,
        'ping',
        XSD::QName.new(Namespace, 'Ping'),
        XSD::QName.new(Namespace, 'PingResponse')
      )

      # When no SOAPAction given, latter method(ping) is called.
    end
  
    def ping(arg)
      arg.text = 'ping'
      arg
    end
  
    def ping_with_soapaction(arg)
      arg.text = 'ping_with_soapaction'
      arg
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_server
    @client = nil
  end

  def teardown
    teardown_server if @server
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
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

  def test_with_soapaction
    wsdl = File.join(DIR, 'ping_nosoapaction.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    rv = @client.ping(:scenario => 'scenario', :origin => 'origin',
      :text => 'text')
    assert_equal('scenario', rv.scenario)
    assert_equal('origin', rv.origin)
    assert_equal('ping', rv.text)
  end

  def test_without_soapaction
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/",
      Server::Namespace)
    @client.add_document_method('ping', Server::Namespace + '/ping',
      XSD::QName.new(Server::Namespace, 'Ping'),
      XSD::QName.new(Server::Namespace, 'PingResponse'))
    @client.wiredump_dev = STDOUT if $DEBUG
    rv = @client.ping(:scenario => 'scenario', :origin => 'origin',
      :text => 'text')
    assert_equal('scenario', rv.scenario)
    assert_equal('origin', rv.origin)
    assert_equal('ping_with_soapaction', rv.text)
  end
end


end; end
