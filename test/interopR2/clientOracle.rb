#!/usr/bin/env ruby

$serverName = 'Oracle'

$server = 'http://ws-interop.oracle.com/soapbuilder/r2/InteropTest'
$noEchoMap = true

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
#doTestGroupB( drv )
submitTestResult
