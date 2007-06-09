#!/usr/bin/env ruby

require 'fcgi'

require 'soap/rpc/cgistub'

class CalcServer < SOAP::RPC::CGIStub
  def initialize(*arg)
    super

    require 'calc'
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

app = CalcServer.new('CalcServer', nil)

FCGI.each do |request|
  app.set_fcgi_request(request)
  app.start
end
