#!/usr/bin/env ruby

$serverName = 'GLUE'

$server = 'http://12.106.211.139:8005/glue/round2'

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
#doTestGroupB( drv )
submitTestResult
