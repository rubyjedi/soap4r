#!/usr/bin/env ruby

$serverName = 'MS SOAP Toolkit 2.0'

require 'clientBase'

$server = 'http://mssoapinterop.org/stk/InteropTyped.wsdl'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
