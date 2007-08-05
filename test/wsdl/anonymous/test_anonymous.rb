require 'test/unit'
require 'wsdl/soap/wsdl2ruby'
require 'soap/rpc/standaloneServer'
require 'soap/wsdlDriver'
require File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'testutil.rb')


if defined?(HTTPClient)

module WSDL; module Anonymous


class TestAnonymous < Test::Unit::TestCase
  class Server < ::SOAP::RPC::StandaloneServer
    Namespace = 'urn:lp'

    def on_init
      add_document_method(
        self,
        Namespace + ':login',
        'login',
        XSD::QName.new(Namespace, 'login'),
        XSD::QName.new(Namespace, 'loginResponse')
      )
    end
  
    def login(arg)
      req = arg.loginRequest
      sess = [req.username, req.password, req.timezone].join
      LoginResponse.new(LoginResponse::LoginResult.new(sess))
    end
  end

  DIR = File.dirname(File.expand_path(__FILE__))
  Port = 17171

  def setup
    setup_server
    setup_clientdef
    @client = nil
  end

  def teardown
    teardown_server
    unless $DEBUG
      File.unlink(pathname('lp.rb'))
      File.unlink(pathname('lpMappingRegistry.rb'))
      File.unlink(pathname('lpDriver.rb'))
    end
    @client.reset_stream if @client
  end

  def setup_server
    @server = Server.new('Test', "urn:lp", '0.0.0.0', Port)
    @server.level = Logger::Severity::ERROR
    @server_thread = TestUtil.start_server_thread(@server)
  end

  def setup_clientdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("lp.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    gen.run
    TestUtil.require(DIR, 'lpDriver.rb', 'lpMappingRegistry.rb', 'lp.rb')
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def compare(expected, actual)
    TestUtil.filecompare(pathname(expected), pathname(actual))
  end

  def test_stubgeneration
    compare("expectedClassDef.rb", "lp.rb")
    compare("expectedMappingRegistry.rb", "lpMappingRegistry.rb")
    compare("expectedDriver.rb", "lpDriver.rb")
  end

  def test_stub
    @client = Lp_porttype.new("http://localhost:#{Port}/")
    @client.wiredump_dev = STDERR if $DEBUG
    request = Login.new(Login::LoginRequest.new("username", "password", "tz"))
    response = @client.login(request)
    assert_equal(LoginResponse::LoginResult, response.loginResult.class)
    assert_equal("usernamepasswordtz", response.loginResult.sessionID)
  end
end


end; end

end
