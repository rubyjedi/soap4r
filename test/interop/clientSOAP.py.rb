#!/usr/bin/env ruby

$serverName = 'SOAP.py'

require 'clientBase'

$server = 'http://208.177.157.221:9595/xmethodsInterop'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
