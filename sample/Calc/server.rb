#!/usr/bin/env ruby

require 'soap/rpc/standaloneServer'

class CalcServer < SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super

    require 'calc'
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

if $0 == __FILE__
  status = CalcServer.new('CalcServer', nil, '0.0.0.0', 7000).start
end
