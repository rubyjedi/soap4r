#!/usr/bin/env ruby
# encoding: UTF-8

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
