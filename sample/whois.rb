#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'

server = 'http://www.SoapClient.com/xml/SQLDataSoap.WSDL'
interface = 'http://www.SoapClient.com/xml/SQLDataSoap.xsd'


###
## Create Proxy
#
def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client.\n"
  f << "Date: #{ Time.now }\n\n"
end

whois = SOAP::Driver.new( Log.new( STDERR ), 'SampleApp', interface, server, proxy )
whois.setWireDumpDev( getWireDumpLogFile )
whois.addMethod( 'ProcessSRL', 'SRLFile', 'RequestName', 'key' )

whois.ProcessSRL( 'WHOIS.SRI', 'whois', 'sarion.com' )
