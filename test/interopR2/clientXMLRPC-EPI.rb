#!/usr/bin/env ruby

$serverName = 'XMLRPC-EPI'
$serverBase = 'http://xmlrpc-epi.sourceforge.net/xmlrpc_php/interop-server.php'
#$serverGroupB = 'http://soapinterop.simdb.com/round2B'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDefBase( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
