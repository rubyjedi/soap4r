require 'soap/wsdlDriver'

wsdl = ARGV.shift || 'SoapBoxWebService.wsdl'
driver = SOAP::WSDLDriverFactory.new(wsdl).create_driver
