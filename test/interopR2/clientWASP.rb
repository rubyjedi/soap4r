#!/usr/bin/env ruby

$serverName = 'WASP'

$serverBase =   'http://soap.systinet.net:6060/InteropService/'
$serverGroupB = 'http://soap.systinet.net:6060/InteropBService/'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
