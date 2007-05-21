## preparing

t = Time.now
starter = Time.local(t.year,t.mon, t.day) + (24 *3600)
ender = starter + 7 * 24 *3600
lattitude = 39.0
longitude = -77.0

## accessing through dynamically generated driver

require 'soap/wsdlDriver'

params = {:maxt => false, :mint => false, :temp => true, :dew => true,
  :pop12 => false, :qpf => false, :sky => false, :snow => false,
  :wspd => false, :wdir => false, :wx => false, :waveh => false,
  :icons => false}

wsdl = "http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl"
drv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
drv.wiredump_dev = STDOUT if $DEBUG
dwml = drv.nDFDgen(lattitude, longitude, 'time-series', starter, ender, params)
puts dwml

require 'xsd/mapping'
data = XSD::Mapping.xml2obj(dwml).data

data.parameters.temperature.each do |temp|
  p temp.name
  p temp.value
end

## accessing through statically generated driver

# run wsdl2ruby.rb to create needed files like this;
# wsdl2ruby.rb --wsdl http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl --type client
require 'defaultDriver.rb'
params = WeatherParametersType.new(false, false, true, true, false, false,
  false, false, false, false, false, false, false)

drv = NdfdXMLPortType.new
drv.wiredump_dev = STDOUT if $DEBUG
dwml = drv.nDFDgen(lattitude, longitude, ProductType::TimeSeries, starter,
  ender, params)
puts dwml
