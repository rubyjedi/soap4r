#!/usr/bin/env ruby

$serverName = 'White Mesa SOAP RPC'

require 'clientBase'

$serverBase = 'http://www.whitemesa.net/interop/std'
$serverGroupB = 'http://www.whitemesa.net/interop/std/groupB'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
