#!/usr/bin/env ruby

$serverName = 'Spray 2001'

require 'clientBase'

$serverBase = 'http://www.dolphinharbor.org/services/interop2001'
$serverGroupB = 'http://www.dolphinharbor.org/services/interopB2001'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

#doTestBase( drvBase )
doTestGroupB( drvGroupB )
