require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module RPC


class TestRPC < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      add_rpc_method(self, 'echo', 'arg1', 'arg2')
    end
  
    def echo(arg1, arg2)
      arg1.family_name = arg2.family_name
      arg1.given_name = arg2.given_name
      arg1
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
    File.unlink(pathname('echo.rb'))
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:rpc", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("rpc.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['force'] = true
    gen.run
    require pathname('echo')
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
    wsdl = File.join(DIR, 'rpc.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG

    ret = @client.echo(Person.new("Na", "Hi"), Person.new("Hi", "Na"))
    assert_equal("Hi", ret.family_name)
    assert_equal("Na", ret.given_name)
  end
end


end; end
