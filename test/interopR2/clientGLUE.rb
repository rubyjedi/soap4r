#!/usr/bin/env ruby

$serverName = 'GLUE'

$serverBase = 'http://www.themindelectric.net:8005/glue/round2.wsdl'
$serverGroupB = 'http://www.themindelectric.net:8005/glue/round2B.wsdl'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
