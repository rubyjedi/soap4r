#!/usr/bin/env ruby

require 'soap/cgistub'

class CalcServer < SOAP::CGIStub
  def initialize(*arg)
    super

    require 'calc'
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

status = CalcServer.new('CalcServer', nil).start
