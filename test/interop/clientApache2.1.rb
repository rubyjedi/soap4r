#!/usr/bin/env ruby

$serverName = 'Apache 2.1'

require 'clientBase'

$server = 'http://nagoya.apache.org:5089/soap/servlet/rpcrouter'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
