#!/usr/bin/env ruby

$serverName = 'GLUE'

$serverBase = 'http://www.themindelectric.net:8005/glue/round2'
$serverGroupB = 'http://www.themindelectric.net:8005/glue/round2B'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
