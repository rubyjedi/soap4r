#!/usr/bin/env ruby

$serverName = 'IDOOX WASP 1.0'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'

$server = 'http://soap.idoox.net:7080/soap/servlet/soap/ilab'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
