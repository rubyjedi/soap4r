require 'soap/rpc/httpserver'
class QueryServer < SOAP::RPC::HTTPServer
  def on_init
    #@log.level = Logger::Severity::DEBUG
    add_method(self, 'hello_world', 'from')
  end

  def hello_world(from)
    sOut="Hellow world from #{from}"
    sOut
  end
end

if $0 == __FILE__
  server = QueryServer.new(
    :BindAddress => '0.0.0.0',
    :Port => 2000,
    :SOAPDefaultNamespace => 'http://localhost:2000/wsdl/hws.wsdl',
    :WSDLDocumentDirectory => '.'
  )
  trap(:INT) do 
    server.shutdown
  end
  server.start
end
