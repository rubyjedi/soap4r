#!/usr/bin/env ruby

$serverName = 'webMethods'

$server = 'http://ewsdemo.webMethods.com:80/soap/rpc'
$noEchoMap = true

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
doTestGroupB( drv )
submitTestResult
