#!/usr/local/bin/ruby

require 'soap/cgistub'
require 'exchange'

class ExchangeServer < SOAP::CGIStub
  def initialize( *arg )
    super
    aServant = Exchange.new
    addServant( aServant )
  end
end

status = ExchangeServer.new( 'SampleStructServer',
  ExchangeServiceNamespace ).start
