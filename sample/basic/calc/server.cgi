#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require 'soap/rpc/cgistub'

class CalcServer < SOAP::RPC::CGIStub
  def initialize(*arg)
    super

    require 'calc'
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

status = CalcServer.new('CalcServer', nil).start
