#!/usr/bin/env ruby

$serverName = 'WASP for C++ 4.0'

$serverBase =   'http://soap.systinet.net:6070/InteropService/'
$serverGroupB = 'http://soap.systinet.net:6070/InteropBService/	'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
