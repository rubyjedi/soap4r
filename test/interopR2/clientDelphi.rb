#!/usr/bin/env ruby

$serverName = 'Delphi'

$serverBase = 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropService.exe/soap/InteropTestPortType'
$serverGroupB = 'http://soap-server.borland.com/WebServices/Interop/cgi-bin/InteropGroupB.exe/soap/InteropTestPortTypeB'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
