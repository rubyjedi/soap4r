require 'test/unit'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module Any


class TestAny < Test::Unit::TestCase
  Namespace = 'urn:example.com:echo'
  TypeNamespace = 'urn:example.com:echo-type'

  class Server < ::SOAP::RPC::StandaloneServer
    def on_init
      # use WSDL to serialize/deserialize
      wsdlfile = File.join(DIR, 'any.wsdl')
      wsdl = WSDL::Importer.import(wsdlfile)
      port = wsdl.services[0].ports[0]
      wsdl_elements = wsdl.collect_elements
      wsdl_types = wsdl.collect_complextypes + wsdl.collect_simpletypes
      rpc_decode_typemap = wsdl_types +
        wsdl.soap_rpc_complextypes(port.find_binding)
      @router.mapping_registry =
        ::SOAP::Mapping::WSDLEncodedRegistry.new(rpc_decode_typemap)
      @router.literal_mapping_registry =
        ::SOAP::Mapping::WSDLLiteralRegistry.new(wsdl_types, wsdl_elements)
      # add method
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(TypeNamespace, 'foo.bar'),
        XSD::QName.new(TypeNamespace, 'foo.bar')
      )
    end
  
    def echo(arg)
      res = FooBar.new(arg.before, arg.after)
      res.set_any([
        ::SOAP::SOAPElement.new("foo", "bar"),
        ::SOAP::SOAPElement.new("baz", "qux")
      ])
      res
      # TODO: arg
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
    File.unlink(pathname('echo.rb')) if !$DEBUG and File.exist?('echo.rb')
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', Namespace, '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("any.wsdl")
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

  def test_any
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("any.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['driver'] = nil
    gen.opt['client_skelton'] = nil
    gen.opt['servant_skelton'] = nil
    gen.opt['standalone_server_stub'] = nil
    gen.opt['force'] = true
    suppress_warning do
      gen.run
    end
    compare("expectedDriver.rb", "echoDriver.rb")
    compare("expectedEcho.rb", "echo.rb")
    compare("expectedService.rb", "echo_service.rb")

    File.unlink(pathname("echo_service.rb"))
    File.unlink(pathname("echo.rb"))
    File.unlink(pathname("echo_serviceClient.rb"))
    File.unlink(pathname("echoDriver.rb"))
    File.unlink(pathname("echoServant.rb"))
  end

  def compare(expected, actual)
    assert_equal(loadfile(expected), loadfile(actual), actual)
  end

  def loadfile(file)
    File.open(pathname(file)) { |f| f.read }
  end

  def suppress_warning
    back = $VERBOSE
    $VERBOSE = nil
    begin
      yield
    ensure
      $VERBOSE = back
    end
  end

  def test_wsdl
    wsdl = File.join(DIR, 'any.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    arg = FooBar.new("before", "after")
    arg.set_any(
      [
        ::SOAP::SOAPElement.new("foo", "bar"),
        ::SOAP::SOAPElement.new("baz", "qux")
      ]
    )
    p @client.echo(arg)
  end
end


end; end
