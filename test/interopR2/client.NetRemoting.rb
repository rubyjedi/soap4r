#!/usr/bin/env ruby

$serverName = '.Net Remoting Web Services'
$serverBase = 'http://www.mssoapinterop.org/remoting/ServiceA.soap'
$serverGroupB = 'http://www.mssoapinterop.org/remoting/ServiceB.soap'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
