#!/usr/bin/env ruby

$serverName = 'eSoap'

$serverBase = 'http://www.quakersoft.net/cgi-bin/interop2_server.cgi'
#$serverGroupB = ''
$noEchoMap = true

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
