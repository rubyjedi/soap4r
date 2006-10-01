require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module Choice


class TestChoice < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:choice'

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(Namespace, 'echoele'),
        XSD::QName.new(Namespace, 'echo_response')
      )
      @router.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry
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
    unless $DEBUG
      File.unlink(pathname('choice.rb'))
      File.unlink(pathname('choiceDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Server::Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("choice.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      require pathname('choice')
      require pathname('choiceMappingRegistry')
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

  def test_wsdl
    wsdl = File.join(DIR, 'choice.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry

    ret = @client.echo(Echoele.new(TerminalID.new("imei", nil)))
    assert_equal("imei", ret.terminalID.imei)
    assert_nil(ret.terminalID.devId)
    ret = @client.echo(Echoele.new(TerminalID.new(nil, 'devId')))
    assert_equal("devId", ret.terminalID.devId)
    assert_nil(ret.terminalID.imei)
  end

  include ::SOAP
  def test_naive
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo', 'urn:choice:echo',
      XSD::QName.new('urn:choice', 'echoele'),
      XSD::QName.new('urn:choice', 'echo_response'))
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = ChoiceMappingRegistry::LiteralRegistry

    echo = SOAPElement.new('echoele')
    echo.add(terminalID = SOAPElement.new('terminalID'))
    terminalID.add(SOAPElement.new('imei', 'imei'))
    ret = @client.echo(echo)
    assert_equal("imei", ret.terminalID.imei)
    assert_nil(ret.terminalID.devId)

    echo = SOAPElement.new('echoele')
    echo.add(terminalID = SOAPElement.new('terminalID'))
    terminalID.add(SOAPElement.new('devId', 'devId'))
    ret = @client.echo(echo)
    assert_equal("devId", ret.terminalID.devId)
    assert_nil(ret.terminalID.imei)
  end
end


end; end
