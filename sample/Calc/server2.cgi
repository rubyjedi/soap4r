#!/usr/local/bin/ruby

require 'soap/cgistub'
class CalcServer < SOAP::CGIStub
  def methodDef
    require 'calc2'
    aServant = CalcService2.new
    addMethod( aServant, 'set', 'newValue' )
    addMethod( aServant, 'get' )
    addMethodAs( aServant, '+', 'add', 'lhs' )
    addMethodAs( aServant, '-', 'sub', 'lhs' )
    addMethodAs( aServant, '*', 'multi', 'lhs' )
    addMethodAs( aServant, '/', 'div', 'lhs' )
  end
end

# Stop this program with Ctrl-C.
status = CalcServer.new( 'CalcServer', 'http://tempuri.org/calcService' ).start
