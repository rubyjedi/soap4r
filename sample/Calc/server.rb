#!/usr/bin/env ruby

require 'soap/standaloneServer'
class CalcServer < SOAP::StandaloneServer
  def initialize( *arg )
    super

    require 'calc'
    aServant = CalcService
    addServant( aServant, 'http://tempuri.org/calcService' )
  end
end

# Stop this program with Ctrl-C.
status = CalcServer.new( 'CalcServer', nil, '0.0.0.0', 7000 ).start
