#!/usr/local/bin/ruby

require 'soap/cgistub'
require 'sampleStruct'

class SampleStructServer < SOAP::CGIStub
  def initialize( *arg )
    super
    aServant = SampleStructService.new
    addServant( aServant )
  end
end

status = SampleStructServer.new( 'SampleStructServer',
  SampleStructServiceNamespace ).start
