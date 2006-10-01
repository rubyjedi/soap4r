require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module Document


class TestArray < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'http://tempuri.org/'

    def on_init
      add_document_method(
        self,
        Namespace + 'echo',
        'echo',
        XSD::QName.new(Namespace, 'echo'),
        XSD::QName.new(Namespace, 'echoResponse')
      )
      self.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    end
  
    def echo(arg)
      arg
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))

  Port = 17171

  def setup
    setup_classdef
    setup_server
    @client = nil
  end

  def teardown
    teardown_server
    File.unlink(pathname('double.rb')) unless $DEBUG
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("double.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['force'] = true
    gen.run
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      require pathname('double')
      require pathname('doubleMappingRegistry')
    ensure
      Dir.chdir(backupdir)
    end
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

  def test_stub
    wsdl = File.join(DIR, 'double.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = ArrayOfDouble[0.1, 0.2, 0.3]
    assert_equal(arg, @client.echo(Echo.new(arg)).ary)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'double.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.literal_mapping_registry = DoubleMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = {:ary => {:double => [0.1, 0.2, 0.3]}}
    assert_equal(arg[:ary][:double], @client.echo(arg).ary)
  end
end


end; end
