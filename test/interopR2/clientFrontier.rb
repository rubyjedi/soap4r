#!/usr/bin/env ruby

$serverName = 'Frontier'

$serverBase = 'http://www.soapware.org:80/xmethodsInterop'
#$serverGroupB = ''

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
