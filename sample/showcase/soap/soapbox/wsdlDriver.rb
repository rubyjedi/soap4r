require 'soap/wsdlDriver'
include SOAP

wsdl = ARGV.shift || 'SoapBoxWebServiceWithRawXML.wsdl'
driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
driver.wiredump_dev = STDOUT

=begin
userinfo = SOAPElement.new(XSD::QName.new('http://www.winfessor.com/SoapBoxWebService/SoapBoxWebService', 'RegisterUser'))
userinfo.add(SOAPElement.new('username', 'NaHi'))
userinfo.add(SOAPElement.new('passowrd', 'passwd'))
userinfo.add(SOAPElement.new('hostname', 'www.example.com'))

s = Struct.new(:username, :password, :hostname)
userinfo = s.new('NaHi', 'nahi', 'jabber.example.com')

s = Struct.new(:username, :password)
userinfo = {:username => 'NaHi', :password => 'nahi'}
driver.RegisterUser(nil, userinfo)
=end

header = { :SessionID => '12345' }
driver.RegisterRemoveUser(header, nil)
