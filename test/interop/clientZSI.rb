#!/usr/bin/env ruby

$serverName = 'Zolera SOAP Infrastructure'

require 'clientBase'

$server = 'http://63.142.188.184:7000'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
