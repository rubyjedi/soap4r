#!/usr/bin/env ruby

$serverName = 'SOAP::Lite'

$server = 'http://services.soaplite.com/interop.cgi'

require 'clientBase'
#$soapAction = 'urn:soapinterop'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

$test_echoMap = true

doTestBase( drv )
doTestGroupB( drv )
submitTestResult
