#!/usr/bin/env ruby

$serverName = 'OpenLink'

$server = 'http://demo.openlinksw.com:8890/Interop'
$noEchoMap = true

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
doTestGroupB( drv )
submitTestResult
