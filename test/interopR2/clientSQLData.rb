#!/usr/bin/env ruby

$serverName = 'SQLData SOAP Server'
$serverBase = 'http://soapclient.com/interop/sqldatainterop.wsdl'
$serverGroupB = 'http://soapclient.com/interop/InteropB.wsdl'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
