#!/usr/bin/env ruby

$serverName = 'ActiveState'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'

$server = 'http://soaptest.activestate.com:8080/PerlEx/soap.plex'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
