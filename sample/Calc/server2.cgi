#!/usr/local/bin/ruby

require 'soap/cgistub'

class CalcServer < SOAP::CGIStub
  def on_init
    require 'calc2'
    servant = CalcService2.new
    add_method(servant, 'set', 'newValue')
    add_method(servant, 'get')
    add_method_as(servant, '+', 'add', 'lhs')
    add_method_as(servant, '-', 'sub', 'lhs')
    add_method_as(servant, '*', 'multi', 'lhs')
    add_method_as(servant, '/', 'div', 'lhs')
  end
end

status = CalcServer.new('CalcServer', 'http://tempuri.org/calcService').start
