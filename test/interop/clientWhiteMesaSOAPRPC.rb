#!/usr/bin/env ruby

$serverName = 'White Mesa SOAP RPC'

require 'clientBase'

$server = 'http://services3.xmetdhos.net:8080/interop'
$soapAction = 'urn:soapinterop#'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDefWithSOAPAction( drv, $soapAction )

doTest( drv )
