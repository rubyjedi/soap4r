#!/usr/bin/env ruby

key = ARGV.shift

require 'soap/driver'

server = 'http://www.SoapClient.com/xml/SQLDataSoap.WSDL'
interface = 'http://www.SoapClient.com/xml/SQLDataSoap.xsd'
logger = nil		# Devel::Logger.new( STDERR )
wireDumpDev = nil	# STDERR
proxy = ENV[ 'HTTP_PROXY' ] || ENV[ 'http_proxy' ]

whois = SOAP::Driver.new( logger, $0, interface, server, proxy )
whois.setWireDumpDev( wireDumpDev )
whois.addMethod( 'ProcessSRL', 'SRLFile', 'RequestName', 'key' )

p whois.ProcessSRL( 'WHOIS.SRI', 'whois', key )
