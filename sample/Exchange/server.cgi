#!/usr/local/bin/ruby

require 'soap/cgistub'
require 'exchange'

class ExchangeServer < SOAP::CGIStub
  def initialize(*arg)
    super
    servant = Exchange.new
    add_servant(servant)
  end
end

status = ExchangeServer.new('SampleStructServer', ExchangeServiceNamespace).start
