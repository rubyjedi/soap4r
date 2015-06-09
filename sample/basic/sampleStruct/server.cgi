#!/usr/bin/env ruby
# encoding: UTF-8

require 'soap/rpc/cgistub'
require 'sampleStruct'

class SampleStructServer < SOAP::RPC::CGIStub
  def initialize(*arg)
    super
    servant = SampleStructService.new
    add_servant(servant)
  end
end

status = SampleStructServer.new('SampleStructServer', SampleStructServiceNamespace).start
