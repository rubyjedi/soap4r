#!/usr/bin/env ruby

$serverName = 'BEA WebLogic 7.0'
$serverBase = 'http://65.193.192.35:7001/InteropRound2Base/WeblogicEchoService'
$serverGroupB = 'http://65.193.192.35:7001/InteropRound2GroupB/WeblogicEchoService'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
