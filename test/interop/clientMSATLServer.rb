#!/usr/bin/env ruby

$serverName = 'MS ATL Server'

require 'clientBase'

$server = 'http://4.34.185.52/ilab/ilab.dll?Handler=Default'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
