#!/usr/bin/env ruby

$serverName = 'gSOAP'

$serverBase = 'http://websrv.cs.fsu.edu/~engelen/interop2.cgi'
$serverGroupB = 'http://websrv.cs.fsu.edu/~engelen/interop2B.cgi'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

$test_echoMap = true

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
