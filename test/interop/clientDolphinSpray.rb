#!/usr/bin/env ruby

$serverName = 'Dolphin Spray Web Services'

require 'clientBase'

$server = 'http://www.dolphinharbor.org/services/interop2001'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
