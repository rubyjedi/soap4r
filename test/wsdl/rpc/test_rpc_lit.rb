require 'test/unit'
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
      # strings.stringItem => Array
      ArrayOfstring[*strings.stringItem]
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
    unless $DEBUG
      File.unlink(pathname('RPC-Literal-TestDefinitions.rb'))
      File.unlink(pathname('RPC-Literal-TestDefinitionsDriver.rb'))
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
    gen.location = pathname("test-rpc-lit.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    backupdir = Dir.pwd
    begin
      Dir.chdir(DIR)
      require pathname('RPC-Literal-TestDefinitions.rb')
      require pathname('RPC-Literal-TestDefinitionsDriver.rb')
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
    wsdl = pathname('test-rpc-lit.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    # response contains only 1 part.
    result = @client.echoStringArray(ArrayOfstring["a", "b", "c"])[0]
    assert_equal(["a", "b", "c"], result.stringItem)
  end

  def test_stub
    drv = SoapTestPortTypeRpc.new("http://localhost:#{Port}/")
    drv.wiredump_dev = STDOUT if $DEBUG
    result = drv.echoStringArray(ArrayOfstring["a", "b", "c"])[0]
    assert_equal(["a", "b", "c"], result.stringItem)
  end
end


end; end
