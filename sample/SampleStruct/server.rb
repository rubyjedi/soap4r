#!/usr/bin/env ruby

require 'soap/standaloneServer'
require 'sampleStruct'

class SampleStructServer < SOAP::StandaloneServer
  def initialize( *arg )
    super
    aServant = SampleStructService.new
    addServant( aServant )
  end
end

status = SampleStructServer.new(
  'SampleStructServer', SampleStructServiceNamespace,
  '0.0.0.0', 7000
).start
