#!/usr/bin/env ruby

$serverName = 'Soap RMI 1.1 BETA9D'
$serverBase = 'http://www.extreme.indiana.edu:1568'
$serverGroupB = 'None'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
