#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'
require 'soap/XMLSchemaDatatypes1999'

server = 'http://webservices.matlus.com/scripts/whoiswebservice.dll/soap/IWhoIs'
interface = 'urn:WhoIsIntf-IWhoIs'


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
whois.addMethodWithSOAPAction( 'GetWhoIs', interface + '#GetWhoIs', 'ADomainName' )

p whois.GetWhoIs( 'sarion.com' )
raise
