#!/usr/bin/env ruby

$serverName = 'IONA XMLBus'

$serverBase = 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/BaseService/BasePort'
$serverGroupB = 'http://interop.xmlbus.com:7002/xmlbus/container/InteropTest/GroupBService/GroupBPort'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
