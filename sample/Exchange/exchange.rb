require 'soap/driver'

ExchangeServiceNamespace = 'http://tempuri.org/exchangeService'

class Exchange
  ForeignServer = "http://services.xmethods.net/soap"
  Namespace = "urn:xmethods-CurrencyExchange"
  Proxy = nil

  def initialize
    @drv = SOAP::Driver.new(nil, nil, Namespace, ForeignServer, Proxy)
    @drv.add_method("getRate", "country1", "country2")
  end

  def rate(country1, country2)
    return @drv.getRate(country1, country2)
  end
end
