#!/usr/bin/env ruby

$serverName = 'MS ASP .NET Web Services'

require 'clientBase'

$serverBase = 'http://mssoapinterop.org/asmx/simple.asmx'
$serverGroupB = 'http://mssoapinterop.org/asmx/simpleB.asmx'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefWithSOAPActionBase( drvBase, $soapAction )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
