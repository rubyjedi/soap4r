#!/usr/bin/env ruby

require 'soap/standaloneServer'
require 'exchange'

class ExchangeServer < SOAP::StandaloneServer
  def initialize( *arg )
    super
    aServant = Exchange.new
    addServant( aServant )
  end
end

status = ExchangeServer.new(
  'SampleStructServer', ExchangeServiceNamespace,
  '0.0.0.0', 7000
).start
