require 'soap/rpc/standaloneServer'

class EchoServer < SOAP::RPC::StandaloneServer
  Namespace = 'urn:echo'
  def on_init
    add_document_method(self, 'echo_soapaction', 'echo', 
      XSD::QName.new(Namespace, 'echoRequest'),
      XSD::QName.new(Namespace, 'echoResponse'))
  end

  def echo(var)
    var
  end
end

if $0 == __FILE__
  server = EchoServer.new('app', EchoServer::Namespace, '0.0.0.0', 7171)
  trap(:INT) do 
    server.shutdown
  end
  server.start
end
