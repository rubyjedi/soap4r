#!/usr/bin/env ruby

$serverName = 'SQLData SOAP Server'

require 'clientBase'

$server = 'http://www.soapclient.com/interop/sqldatainterop.wsdl'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
