#!/usr/bin/env ruby

$serverName = '4S4C'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'

$server = 'http://soap.4s4c.com/ilab/soap.asp'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
