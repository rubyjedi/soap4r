#!/usr/bin/env ruby

$serverName = 'MS ASP .NET Web Services'
$serverBase = 'http://mssoapinterop.org/asmx/simple.asmx'
$serverGroupB = 'http://mssoapinterop.org/asmx/simpleB.asmx'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefWithSOAPActionBase( drvBase, $soapAction )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
#submitTestResult
