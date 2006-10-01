require 'test/unit'
require 'soap/rpc/httpserver'
require 'soap/rpc/driver'
require 'rexml/document'


module SOAP


class TestResponseAsXml < Test::Unit::TestCase
  Namespace = "urn:example.com:hello"
  class Server < ::SOAP::RPC::HTTPServer
    def on_init
      add_method(self, 'hello', 'name')
    end
  
    def hello(name)
      "hello #{name}"
    end
  end

  Port = 17171

  def setup
    setup_server
    setup_client
  end

  def setup_server
    @server = Server.new(
      :Port => Port,
      :BindAddress => "0.0.0.0",
      :AccessLog => [],
      :SOAPDefaultNamespace => Namespace
    )
    @server.level = Logger::Severity::ERROR
    @server_thread = start_server_thread(@server)
  end

  def setup_client
    @client = ::SOAP::RPC::Driver.new("http://localhost:#{Port}/", Namespace)
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method('hello', 'name')
  end

  def teardown
    teardown_server
    teardown_client
  end

  def teardown_server
    @server.shutdown
    @server_thread.kill
    @server_thread.join
  end

  def teardown_client
    @client.reset_stream
  end

  def start_server_thread(server)
    t = Thread.new {
      Thread.current.abort_on_exception = true
      server.start
    }
    t
  end

  RESPONSE_AS_XML=<<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:helloResponse xmlns:n1="urn:example.com:hello"
        env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return xsi:type="xsd:string">hello world</return>
    </n1:helloResponse>
  </env:Body>
</env:Envelope>
__XML__

  def test_hello
    assert_equal("hello world", @client.hello("world"))
    @client.return_response_as_xml = true
    xml = @client.hello("world")
    assert_equal(RESPONSE_AS_XML, xml, [RESPONSE_AS_XML, xml].join("\n\n"))
    doc = REXML::Document.new(@client.hello("world"))
    assert_equal("hello world",
      REXML::XPath.match(doc, "//*[name()='return']")[0].text)
  end
end


end
