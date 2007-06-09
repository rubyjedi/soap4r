require 'xsd/qname'

# {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}weatherParametersType
class WeatherParametersType
  attr_accessor :maxt
  attr_accessor :mint
  attr_accessor :temp
  attr_accessor :dew
  attr_accessor :pop12
  attr_accessor :qpf
  attr_accessor :sky
  attr_accessor :snow
  attr_accessor :wspd
  attr_accessor :wdir
  attr_accessor :wx
  attr_accessor :waveh
  attr_accessor :icons

  def initialize(maxt = nil, mint = nil, temp = nil, dew = nil, pop12 = nil, qpf = nil, sky = nil, snow = nil, wspd = nil, wdir = nil, wx = nil, waveh = nil, icons = nil)
    @maxt = maxt
    @mint = mint
    @temp = temp
    @dew = dew
    @pop12 = pop12
    @qpf = qpf
    @sky = sky
    @snow = snow
    @wspd = wspd
    @wdir = wdir
    @wx = wx
    @waveh = waveh
    @icons = icons
  end
end

# {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}formatType
class FormatType < ::String
  C_12Hourly = FormatType.new("12 hourly")
  C_24Hourly = FormatType.new("24 hourly")
end

# {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}productType
class ProductType < ::String
  Glance = ProductType.new("glance")
  TimeSeries = ProductType.new("time-series")
end
