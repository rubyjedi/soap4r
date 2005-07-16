#!/usr/bin/env ruby

require 'soap/rpc/standaloneServer'

class Server < SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super
    add_rpc_method(self, 'echo', 'arg')
    add_rpc_method(self, 'echo_base64', 'arg')
  end

  def echo(arg)
    p arg
    arg
  end

  def echo_base64(arg)
    p arg
    SOAP::SOAPBase64.new(arg)
  end
end

if $0 == __FILE__
  server = Server.new('Server', 'http://tempuri.org/base64Service',
    '0.0.0.0', 7000)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
