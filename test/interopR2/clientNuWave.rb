#!/usr/bin/env ruby

$serverName = 'NuWave'

$server = 'http://interop.nuwave-tech.com:7070/interop/base.wsdl'
$noEchoMap = true

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
#doTestGroupB( drv )
submitTestResult
