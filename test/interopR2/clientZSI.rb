#!/usr/bin/env ruby

$serverName = 'ZSI'

$serverBase = 'http://63.142.188.184:7000'
#$serverGroupB = ''

require 'clientBase'
$soapAction = 'urn:soapinterop'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
