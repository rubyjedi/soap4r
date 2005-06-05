require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module RPC


class TestRPCLIT < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = "http://soapbuilders.org/rpc-lit-test"

    def on_init
      self.generate_explicit_type = false
      add_rpc_operation(self, 
        XSD::QName.new(Namespace, 'echoStringArray'),
        nil,
        'echoStringArray', [
          ['in', 'inputStringArray', nil],
          ['retval', 'return', nil]
        ],
        {
          :request_style => :rpc,
          :request_use => :literal,
          :response_style => :rpc,
          :response_use => :literal
        }
      )
    end
  
    def echoStringArray(strings)
      strings
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_server
    setup_classdef
    @client = nil
  end

  def teardown
    teardown_server
    File.unlink(pathname('RPC-Literal-TestDefinitions.rb'))
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("test-rpc-lit.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['force'] = true
    gen.run
    require pathname('RPC-Literal-TestDefinitions.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def start_server_thread(server)
    t = Thread.new {
      Thread.current.abort_on_exception = true
      server.start
    }
    t
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    assert_equal(["a", "b", "c"], @client.echoStringArray(["a", "b", "c"]).item)
  end
end


end; end
