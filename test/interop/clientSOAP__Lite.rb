#!/usr/bin/env ruby

$serverName = 'SOAP::Lite'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'


$server = 'http://services.soaplite.com/interop.cgi'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
