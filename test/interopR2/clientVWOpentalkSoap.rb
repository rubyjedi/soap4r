#!/usr/bin/env ruby

$serverName = 'VW OpentalkSoap'

$server = 'http://www.cincomsmalltalk.com/soap/interop'
$serverGroupB = 'http://www.cincomsmalltalk.com/r2groupb/interop'
$noEchoMap = true

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDefBase( drv )

drvGroupB = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drv )
doTestGroupB( drvGroupB )
submitTestResult
