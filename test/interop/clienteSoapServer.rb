#!/usr/bin/env ruby

$serverName = 'eSoapServer'

require 'clientBase'

$server = 'http://www.connecttel.com/cgi-bin/esoapserver.cgi'

$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
