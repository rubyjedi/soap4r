require 'soap/driver'
require 'iExchange'

class Exchange
  ForeignServer = "http://services.xmethods.net/soap"
  Namespace = "urn:xmethods-CurrencyExchange"
  Proxy = nil

  def initialize
    @drv = SOAP::Driver.new( nil, nil, Namespace, ForeignServer, Proxy )
    @drv.addMethod( "getRate", "country1", "country2" )
    @called = 0
    @startTime = Time.now
  end

  attr_reader :called
  attr_reader :startTime

  def getRate( country1, country2 )
    @called += 1
    return @drv.getRate( country1, country2 )
  end
end
