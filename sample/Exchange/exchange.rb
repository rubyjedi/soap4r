require 'soap/driver'
require 'iExchange'

class Exchange
  ForeignServer = "http://services.xmethods.net/soap"
  Namespace = "urn:xmethods-CurrencyExchange"
  Proxy = nil

  def initialize
    @drv = SOAP::Driver.new( nil, nil, Namespace, ForeignServer, Proxy )
    @drv.addMethod( "getRate", "country1", "country2" )
  end

  def getRate( country1, country2 )
    return @drv.getRate( country1, country2 )
  end
end
