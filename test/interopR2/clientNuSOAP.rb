#!/usr/bin/env ruby

$serverName = 'NuSOAP'

$serverBase = 'http://dietrich.ganx4.com/nusoap/testbed/round2_base_server.php'
$serverGroupB = 'http://dietrich.ganx4.com/nusoap/testbed/round2_groupb_server.php'

require 'clientBase'
log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO        # Log::SEV_WARN, Log::SEV_DEBUG

drvBase = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
