#!/usr/bin/env ruby

$serverName = 'Microsoft Soap Toolkit V2'
$serverBase = 'http://mssoapinterop.org/stk/InteropTyped.wsdl'
$serverGroupB = 'http://mssoapinterop.org/stk/InteropB.wsdl'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, 'urn:soapinterop' )
methodDefBase( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
