#!/usr/bin/env ruby

$serverName = 'Microsoft Soap Toolkit 3.0'
$serverBase = 'http://mssoapinterop.org/stkV3/InteropTyped.wsdl'
$serverGroupB = 'http://mssoapinterop.org/stkV3/InteropBtyped.wsdl'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
