#!/usr/bin/env ruby

require 'soap/cgistub'
class CalcServer < SOAP::CGIStub
  def initialize( *arg )
    super

    require 'calc'
    aServant = CalcService
    addServant( aServant, 'http://tempuri.org/calcService' )
  end
end

# Stop this program with Ctrl-C.
status = CalcServer.new( 'CalcServer', nil ).start
