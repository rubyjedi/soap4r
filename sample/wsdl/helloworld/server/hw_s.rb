require 'soap/rpc/standaloneServer'
class QueryServer < SOAP::RPC::StandaloneServer
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
  # You need to use ../changesTohttpserver/*.rb to supply WSDL files in the
  # specified directory.  It may be merged in the future (with some changes)
  # server = QueryServer.new('hws', 'http://localhost:2000/wsdl/hws.wsdl', '0.0.0.0', 2000, "c:/soap4r-20050420/sample/soap/helloworld")

  server = QueryServer.new('hws', 'http://localhost:2000/wsdl/hws.wsdl', '0.0.0.0', 2000)
  trap(:INT) do 
    server.shutdown
  end
  server.start
end
