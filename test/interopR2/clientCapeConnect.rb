#!/usr/bin/env ruby

$serverName = 'CapeConnect'

$serverBase = 'http://interop.capeclear.com/ccx/soapbuilders-round2'
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
