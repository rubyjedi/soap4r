require 'soap/rpc/standaloneServer'

class Server < SOAP::RPC::StandaloneServer
  def on_init
    add_method(self, 'hash')
  end

  def hash(arg)
    arg.update({5=>6, 7=>8})
  end
end

if $0 == __FILE__
  server = Server.new('svr', 'urn:www.example.org:hashsample', '0.0.0.0', 7171)
  trap(:INT) { server.shutdown }
  server.start
end
