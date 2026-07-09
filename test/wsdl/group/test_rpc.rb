# encoding: UTF-8
require 'helper'
require 'testutil'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'


module WSDL; module Group


class TestGroup < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:group'
    TypeNamespace = 'urn:grouptype'

    def on_init
      add_document_method(
        self,
        Namespace + ':echo',
        'echo',
        XSD::QName.new(TypeNamespace, 'groupele'),
        XSD::QName.new(TypeNamespace, 'groupele')
      )
      self.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    end
  
    def echo(arg)
      # arg
      # need to convert for 'any'
      ret = Groupele_type.new(arg.comment, arg.element, arg.eletype, arg.var)
      ret.xmlattr_attr_max = arg.xmlattr_attr_max
      ret.xmlattr_attr_min = arg.xmlattr_attr_min
      ret.set_any([::SOAP::SOAPElement.new("foo", arg.foo)])
      ret
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
    teardown_server if @server
    unless $DEBUG
      File.unlink(pathname('echo.rb')) if File.file?(pathname('echo.rb'))
      File.unlink(pathname('echoMappingRegistry.rb')) if File.file?(pathname('echoMappingRegistry.rb'))
      File.unlink(pathname('echoDriver.rb')) if File.file?(pathname('echoDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:group", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("group.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'echoDriver.rb', 'echoMappingRegistry.rb', 'echo.rb')
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

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def test_generate
    compare("expectedClassdef.rb", "echo.rb")
    compare("expectedMappingRegistry.rb", "echoMappingRegistry.rb")
    compare("expectedDriver.rb", "echoDriver.rb")
  end

  # Regression test for a <xsd:group ref="..."/> used as a complexType's
  # sole, direct content (groupdirect_type in group.wsdl), as opposed to
  # groupele_type's group ref nested inside an explicit <xsd:sequence>.
  # Before this was fixed, generating a class definition for a complexType
  # shaped this way crashed with "undefined method 'have_any?' for an
  # instance of WSDL::XMLSchema::Group" (classDefCreator.rb calling
  # ComplexType#elements, which delegates straight to the bare Group
  # instance since it's the complexType's only content, but Group didn't
  # yet have any of the ComplexType-derived methods that requires). This
  # test only needs test_generate (above) to have already run without
  # raising to prove the crash is fixed; it additionally confirms the
  # generated class actually has the fields pulled in from the referenced
  # group (comment/element/eletype, from common_element's own nested
  # group ref to common plus a choice) rather than silently coming up
  # empty.
  def test_groupdirect_classdef
    obj = Groupdirect_type.new("a comment", "an element", nil)
    assert_equal("a comment", obj.comment)
    assert_equal("an element", obj.element)
    assert_nil(obj.eletype)
    assert_respond_to(obj, :set_any)
  end

  def test_wsdl
    wsdl = File.join(DIR, 'group.wsdl')
    @client = ::SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
    @client.endpoint_url = "http://localhost:#{Port}/"
    @client.wiredump_dev = STDOUT if $DEBUG
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    #
    do_test_arg
  end

  def test_naive
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/")
    @client.add_document_method('echo', 'urn:group:echo',
      XSD::QName.new('urn:grouptype', 'groupele'),
      XSD::QName.new('urn:grouptype', 'groupele'))
    @client.literal_mapping_registry = EchoMappingRegistry::LiteralRegistry
    @client.wiredump_dev = STDOUT if $DEBUG
    #
    do_test_arg
  end

  def test_stub
    @client = Group_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDOUT if $DEBUG
    #
    do_test_arg
  end

  def do_test_arg
    arg = Groupele_type.new
    arg.comment = "comment"
    arg.set_any(
      [::SOAP::SOAPElement.new("foo", "bar")]
    )
    arg.eletype = "eletype"
    arg.var = "var"
    arg.xmlattr_attr_min = -3
    arg.xmlattr_attr_max = 3
    ret = @client.echo(arg)
    assert_equal(arg.comment, ret.comment)
    assert_equal(arg.eletype, ret.eletype)
    assert_nil(ret.element)
    assert_equal(arg.var, ret.var)
    assert_equal("bar", ret.foo)
  end
end


end; end
