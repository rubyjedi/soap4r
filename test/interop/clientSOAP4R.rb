#!/usr/bin/env ruby

$serverName = 'SOAP4R'

require 'clientBase'

$server = 'http://dora/~nakahiro/interop.cgi'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
