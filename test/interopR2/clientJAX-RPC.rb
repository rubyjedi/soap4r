#!/usr/bin/env ruby

$serverName = 'JAX-RPC'

$serverBase = 'http://soapinterop.java.sun.com:80/round2/base'
$serverGroupB = 'http://soapinterop.java.sun.com:80/round2/groupb'
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
