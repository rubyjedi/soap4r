#!/usr/bin/env ruby

$serverName = 'GLUE'

require 'clientBase'

$server = 'http://209.61.190.164:8004/glue/http://soapinterop.org/'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
